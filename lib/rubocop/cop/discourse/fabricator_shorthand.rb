# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      # When fabricating a record without custom attributes, we can use the
      # fabricator shorthand as long as the identifier matches the fabricator
      # name.
      #
      # @example
      #
      # # bad
      # fab!(:user) { Fabricate(:user) }
      #
      # # good
      # fab!(:user)
      #
      # When the variable name doesn't match the fabricator name but no custom
      # attributes are used, we can use a more explicit syntax.
      #
      # @example
      #
      # # bad
      # fab!(:other_user) { Fabricate(:user) }
      #
      # # good
      # fab!(:other_user, :user)
      #
      # When using custom attributes, the block form must be used.
      #
      # @example
      #
      # # good
      # fab!(:user) { Fabricate(:user, trust_level: TrustLevel[0]) }
      #
      # # good
      # fab!(:other_user) { Fabricate(:user, trust_level: TrustLevel[0]) }
      class FabricatorShorthand < Base
        extend AutoCorrector
        include IgnoredNode

        def_node_matcher :same_name_fabricator?, <<-MATCHER
          (block
            $(send nil? :fab!
              (sym $_identifier))
            (args)
            (send nil? :Fabricate
              (sym $_identifier)))
        MATCHER

        def_node_matcher :different_name_fabricator?, <<-MATCHER
          (block
            $(send nil? :fab!
              (sym $_variable_name))
            (args)
            (send nil? :Fabricate
              (sym $_fabricator_name)))
        MATCHER

        def on_block(node)
          same_name_fabricator?(node) do |expression, _identifier|
            add_offense(node, message: message_for_matching(expression.source)) do |corrector|
              next if part_of_ignored_node?(node)
              corrector.replace(node, expression.source)
            end
            ignore_node(node)
            return
          end

          different_name_fabricator?(node) do |expression, variable_name, fabricator_name|
            # Only apply when names don't match but there are no extra arguments
            next if variable_name == fabricator_name || has_extra_arguments?(node)

            add_offense(
              node,
              message: message_for_different_names(variable_name, fabricator_name),
            ) do |corrector|
              next if part_of_ignored_node?(node)
              corrector.replace(node, "fab!(:#{variable_name}, :#{fabricator_name})")
            end
            ignore_node(node)
          end
        end

        private

        def has_extra_arguments?(node)
          fabricate_node = node.children.last
          # Check if Fabricate has more than one argument
          fabricate_node.arguments.size > 1
        end

        def message_for_matching(expression)
          "Use the fabricator shorthand: `#{expression}`"
        end

        def message_for_different_names(variable_name, fabricator_name)
          "Use the fabricator shorthand: `fab!(:#{variable_name}, :#{fabricator_name})`"
        end
      end
    end
  end
end
