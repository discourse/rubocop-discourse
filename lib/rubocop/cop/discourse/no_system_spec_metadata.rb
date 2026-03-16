# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      # System spec metadata is inferred from the file path, so explicit
      # `type: :system` and `system: true` metadata on `RSpec.describe` is redundant.
      #
      # @example
      #   # bad
      #   RSpec.describe "login", system: true do
      #   end
      #
      #   # good
      #   RSpec.describe "login" do
      #   end
      class NoSystemSpecMetadata < Base
        extend AutoCorrector

        MSG = "Remove redundant `type: :system` and `system: true` metadata from `RSpec.describe`."
        RESTRICT_ON_SEND = %i[describe].freeze

        def_node_matcher :describe?, <<~PATTERN
          (send
            {nil? (const nil? :RSpec)}
            :describe
            ...
          )
        PATTERN

        def_node_matcher :system_type_pair?, <<~PATTERN
          (pair (sym :type) (sym :system))
        PATTERN

        def_node_matcher :system_true_pair?, <<~PATTERN
          (pair (sym :system) true)
        PATTERN

        def on_send(node)
          return unless describe?(node)
          return unless node.last_argument&.hash_type?

          hash = node.last_argument
          offending_pairs =
            hash.pairs.select { |pair| system_type_pair?(pair) || system_true_pair?(pair) }

          return if offending_pairs.empty?

          add_offense(offending_pairs.first) do |corrector|
            corrector.replace(node, corrected_send_source(node, hash, offending_pairs))
          end
        end

        private

        def corrected_send_source(node, hash, offending_pairs)
          remaining_pairs = hash.pairs - offending_pairs
          before_hash = source_for(node.source_range.begin_pos, hash.source_range.begin_pos)
          after_hash = source_for(hash.source_range.end_pos, node.source_range.end_pos)

          return "#{before_hash.sub(/,\s*\z/m, "")}#{after_hash}" if remaining_pairs.empty?

          "#{before_hash}#{corrected_hash_source(hash, remaining_pairs)}#{after_hash}"
        end

        def corrected_hash_source(hash, remaining_pairs)
          body =
            remaining_pairs
              .each_with_index
              .map do |pair, index|
                separator = index.zero? ? "" : pair_separator(hash, pair)
                "#{separator}#{pair.source}"
              end
              .join

          return body unless hash.braces?

          return "{ #{body} }" unless hash.multiline?

          indentation = " " * remaining_pairs.first.loc.expression.column
          closing_indentation = " " * hash.loc.end.column

          "{\n#{indentation}#{body}\n#{closing_indentation}}"
        end

        def pair_separator(hash, pair)
          return ", " unless hash.multiline?

          ",\n#{" " * pair.loc.expression.column}"
        end

        def source_for(begin_pos, end_pos)
          processed_source.buffer.source[begin_pos...end_pos]
        end
      end
    end
  end
end
