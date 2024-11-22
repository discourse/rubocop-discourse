# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Services
        # Put empty lines around multiline blocks.
        #
        # @example
        #   # bad
        #   model :my_model
        #   params do
        #     attribute :my_attribute
        #     validates :my_attribute, presence: true
        #   end
        #   policy :my_policy
        #   step :another_step
        #
        #   # good
        #   model :my_model
        #
        #   params do
        #     attribute :my_attribute
        #     validates :my_attribute, presence: true
        #   end
        #
        #   policy :my_policy
        #   step :another_step
        #
        class EmptyLinesAroundBlocks < Base
          extend AutoCorrector

          MSG = "Add empty lines around a step block."

          def_node_matcher :service_include?, <<~MATCHER
            (class _ _
             {
               (begin <(send nil? :include (const (const nil? :Service) :Base)) ...>)
               <(send nil? :include (const (const nil? :Service) :Base)) ...>
             }
            )
          MATCHER

          def_node_matcher :top_level_block?, <<~MATCHER
            (block (send nil? _) ...)
          MATCHER

          def on_class(node)
            return unless service_include?(node)
            @service = true
          end

          def on_block(node)
            return unless service?
            return unless top_level_block?(node)
            return if node.single_line?

            if missing_empty_lines?(node)
              add_offense(node, message: MSG) do |corrector|
                if missing_empty_line_before?(node) &&
                     corrected_after.exclude?(node.left_sibling)
                  corrected_before << node
                  corrector.insert_before(
                    node.loc.expression.adjust(
                      begin_pos: -node.loc.expression.column
                    ),
                    "\n"
                  )
                end
                if missing_empty_line_after?(node) &&
                     corrected_before.exclude?(node.right_sibling)
                  corrected_after << node
                  corrector.insert_after(node.loc.end, "\n")
                end
              end
            end
          end

          private

          def service?
            @service
          end

          def missing_empty_lines?(node)
            missing_empty_line_before?(node) || missing_empty_line_after?(node)
          end

          def missing_empty_line_before?(node)
            processed_source[node.loc.expression.line - 2].present? &&
              node.left_siblings.present?
          end

          def missing_empty_line_after?(node)
            processed_source[node.loc.end.line].present? &&
              node.right_siblings.present?
          end

          def corrected_before
            @corrected_before ||= []
          end

          def corrected_after
            @corrected_before ||= []
          end
        end
      end
    end
  end
end
