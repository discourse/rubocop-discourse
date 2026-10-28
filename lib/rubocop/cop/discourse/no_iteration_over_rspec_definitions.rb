# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      class NoIterationOverRSpecDefinitions < Base
        include RuboCop::RSpec::Language

        DEFAULT_LANGUAGE =
          YAML
            .safe_load_file(
              File.join(
                Gem.loaded_specs.fetch("rubocop-rspec").full_gem_path,
                "config/default.yml",
              ),
            )
            .fetch("RSpec")
            .fetch("Language")
        private_constant :DEFAULT_LANGUAGE

        MSG =
          "Do not generate RSpec examples or groups with iterators. Write each definition explicitly."

        ITERATION_METHODS = %i[
          combination
          permutation
          product
          repeated_combination
          repeated_permutation
          step
          with_index
          with_object
        ].freeze
        private_constant :ITERATION_METHODS

        def on_new_investigation
          super
          RuboCop::RSpec::Language.config = config.dig("RSpec", "Language") || DEFAULT_LANGUAGE
        end

        def on_send(node)
          return unless rspec_definition?(node)
          return if inside_runtime_scope?(node)

          node.each_ancestor do |ancestor|
            if ancestor.def_type? || ancestor.defs_type? || ancestor.class_type? ||
                 ancestor.module_type?
              break
            end
            if ancestor.any_block_type? && rspec_definition?(ancestor.send_node)
              next if ancestor.send_node.equal?(node)

              break
            end

            next unless iteration?(ancestor)

            add_offense(node.loc.selector)
            break
          end
        end

        private

        def_node_matcher :rspec_definition?, <<~PATTERN
          (send #rspec? {#ExampleGroups.all #Examples.all} ...)
        PATTERN

        def_node_matcher :runtime_scope?, <<~PATTERN
          (any_block (send #rspec? {#Examples.all #Hooks.all #Helpers.all #Subjects.all} ...) ...)
        PATTERN

        def inside_runtime_scope?(node)
          node
            .each_ancestor(:block, :numblock, :itblock)
            .any? { |ancestor| !ancestor.send_node.equal?(node) && runtime_scope?(ancestor) }
        end

        def iteration?(node)
          return true if node.loop_keyword?
          return false unless node.any_block_type?

          method_call = node.send_node
          method_call.enumerator_method? || method_call.enumerable_method? ||
            ITERATION_METHODS.include?(node.method_name)
        end
      end
    end
  end
end
