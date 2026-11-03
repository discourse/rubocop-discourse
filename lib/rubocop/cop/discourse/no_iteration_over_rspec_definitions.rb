# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      # Define RSpec examples and groups outside iterators so scenarios can be
      # selected by file and line.
      #
      # @example
      #   # bad
      #   %w[latest top].each do |filter|
      #     it "returns the #{filter} list" do
      #       get "/#{filter}"
      #       expect(response.status).to eq(200)
      #     end
      #   end
      #
      #   # good
      #   it "returns the latest list" do
      #     get "/latest"
      #     expect(response.status).to eq(200)
      #   end
      #
      #   it "returns the top list" do
      #     get "/top"
      #     expect(response.status).to eq(200)
      #   end
      #
      # Use shared examples for substantial repeated checks, with named contexts
      # and keyword arguments.
      #
      # @example
      #   # good
      #   shared_examples "a public topic list" do |path:|
      #     before { get path }
      #
      #     it "returns JSON successfully" do
      #       expect(response.status).to eq(200)
      #       expect(response.media_type).to eq("application/json")
      #     end
      #
      #     it "includes topic data" do
      #       expect(response.parsed_body["topic_list"]).to include("topics" => be_an(Array))
      #     end
      #
      #     it "includes user data" do
      #       expect(response.parsed_body["users"]).to be_an(Array)
      #     end
      #   end
      #
      #   context "with latest topics" do
      #     include_examples "a public topic list", path: "/latest.json"
      #   end
      #
      #   context "with top topics" do
      #     include_examples "a public topic list", path: "/top.json"
      #   end
      class NoIterationOverRSpecDefinitions < RuboCop::Cop::RSpec::Base
        MSG = "Do not generate RSpec examples or groups with iterators."

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
