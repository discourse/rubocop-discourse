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
      # When using custom attributes or the identifier doesn't match, the
      # shorthand can't be used.
      #
      # @example
      #
      # # good
      # fab!(:user) { Fabricate(:user, trust_level: TrustLevel[0]) }
      #
      # # good
      # fab!(:another_user) { Fabricate(:user) }
      class FabricatorShorthand < Base
        extend AutoCorrector
        include IgnoredNode

        def_node_matcher :offending_fabricator?, <<-MATCHER
          (block
            $(send nil? :fab!
              (sym $_identifier))
            (args)
            (send nil? :Fabricate
              (sym $_identifier)))
        MATCHER

        def on_block(node)
          offending_fabricator?(node) do |expression, _identifier|
            add_offense(
              node,
              message: message(expression.source)
            ) do |corrector|
              next if part_of_ignored_node?(node)
              corrector.replace(node, expression.source)
            end
            ignore_node(node)
          end
        end

        private

        def message(expression)
          "Use the fabricator shorthand: `#{expression}`"
        end
      end
    end
  end
end
