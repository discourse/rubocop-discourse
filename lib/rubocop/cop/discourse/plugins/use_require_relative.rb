# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Plugins
        # Use `require_relative` to load dependencies.
        #
        # @example
        #   # bad
        #   load File.expand_path("../lib/my_file.rb", __FILE__)
        #
        #   # good
        #   require_relative "lib/my_file"
        #
        class UseRequireRelative < Base
          MSG = "Use `require_relative` instead of `load`."
          RESTRICT_ON_SEND = [:load].freeze

          def_node_matcher :load_called?, <<~MATCHER
            (send nil? :load _)
          MATCHER

          def on_send(node)
            return unless load_called?(node)
            add_offense(node, message: MSG)
          end
        end
      end
    end
  end
end
