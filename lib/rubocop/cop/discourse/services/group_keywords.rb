# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Services
        # Don’t put empty lines between keywords that are not multiline blocks.
        #
        # @example
        #   # bad
        #   model :my_model
        #
        #   policy :my_policy
        #
        #   try { step :might_raise }
        #
        #   # good
        #   model :my_model
        #   policy :my_policy
        #   try { step :might_raise }
        #
        class GroupKeywords < Base
          extend AutoCorrector

          MSG = "Group one-liner steps together by removing extra empty lines."
          RESTRICT_ON_SEND = %i[step model policy].freeze

          def_node_matcher :service_include?, <<~MATCHER
            (class _ _
             {
               (begin <(send nil? :include (const (const nil? :Service) :Base)) ...>)
               <(send nil? :include (const (const nil? :Service) :Base)) ...>
             }
            )
          MATCHER

          def on_class(node)
            return unless service_include?(node)
            @service = true
          end

          def on_send(node)
            return unless service?
            return unless top_level?(node)
            return unless extra_empty_line_after?(node)

            add_offense(node, message: MSG) do |corrector|
              range =
                node.loc.expression.end.with(
                  end_pos: node.right_sibling.loc.expression.begin_pos
                )
              content = range.source.gsub(/^(\n)+/, "\n")
              corrector.replace(range, content)
            end
          end

          private

          def service?
            @service
          end

          def extra_empty_line_after?(node)
            processed_source[node.loc.expression.line].blank? &&
              (
                service_keyword?(node.right_sibling) ||
                  single_line_block?(node.right_sibling)
              )
          end

          def service_keyword?(node)
            return unless node
            node.send_type? && RESTRICT_ON_SEND.include?(node.method_name)
          end

          def single_line_block?(node)
            return unless node
            node.block_type? && node.single_line?
          end

          def top_level?(node)
            while (!node.root?)
              node = node.parent
              return if %i[begin class block].exclude?(node.type)
            end
            true
          end
        end
      end
    end
  end
end
