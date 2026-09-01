# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Services
        # Wrap mutable `attribute` defaults in a proc — `ActiveModel::Attributes`
        # shares the literal across instances, so mutations leak between calls.
        # `:array`-typed attributes are exempt; the type dups on read.
        #
        # @example
        #   # bad
        #   options do
        #   attribute :overrides, default: {}
        #     attribute :ids, default: [1, 2]
        #   end
        #
        #   # good
        #   options do
        #   attribute :overrides, default: -> { {} }
        #     attribute :ids, default: -> { [1, 2] }
        #     attribute :tags, :array, default: [] # :array dups per read
        #   end
        #
        class MutableAttributeDefault < Base
          extend AutoCorrector

          MSG =
            "Mutable `default: %<source>s` is shared across all instances; wrap it in a proc: `-> { %<source>s }`."
          RESTRICT_ON_SEND = %i[attribute].freeze

          def_node_matcher :service_include?, <<~MATCHER
            (class _ _
             {
               (begin <(send nil? :include (const (const nil? :Service) :Base)) ...>)
               <(send nil? :include (const (const nil? :Service) :Base)) ...>
             }
            )
          MATCHER

          def_node_matcher :mutable_default, <<~PATTERN
            (send nil? :attribute _ ... (hash <(pair (sym :default) ${hash array}) ...>))
          PATTERN

          def_node_matcher :array_typed?, <<~PATTERN
            (send nil? :attribute _ (sym :array) ...)
          PATTERN

          def on_class(node)
            @service = true if service_include?(node)
          end

          def on_send(node)
            return unless @service
            return if array_typed?(node)
            default = mutable_default(node)
            return unless default

            source = default.source
            add_offense(default, message: format(MSG, source: source)) do |corrector|
              corrector.replace(default, "-> { #{source} }")
            end
          end
        end
      end
    end
  end
end
