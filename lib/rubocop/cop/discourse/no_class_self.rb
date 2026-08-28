# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      class NoClassSelf < Base
        MSG = "Do not use `class << self`."

        def on_sclass(node)
          return unless node.identifier.self_type?

          add_offense(node.loc.keyword.join(node.identifier.source_range), message: MSG)
        end
      end
    end
  end
end
