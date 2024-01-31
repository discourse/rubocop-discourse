# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Plugins
        # Using `DiscourseEvent.on` leaves the handler enabled when the plugin is disabled.
        #
        # @example
        #   # bad
        #   DiscourseEvent.on(:event) { do_something }
        #
        #   # good
        #   on(:event) { do_something }
        #
        class UsePluginInstanceOn < Base
          MSG =
            "Use `on` instead of `DiscourseEvent.on` as the latter will listen to events even if the plugin is disabled."
          NOT_OUTSIDE_PLUGIN_RB =
            "Don’t call `DiscourseEvent.on` outside `plugin.rb`."
          RESTRICT_ON_SEND = [:on].freeze

          def_node_matcher :discourse_event_on?, <<~MATCHER
            (send (const nil? :DiscourseEvent) :on _)
          MATCHER

          def on_send(node)
            return unless discourse_event_on?(node)
            return add_offense(node, message: MSG) if in_plugin_rb_file?
            add_offense(node, message: NOT_OUTSIDE_PLUGIN_RB)
          end

          private

          def in_plugin_rb_file?
            processed_source.path.split("/").last == "plugin.rb"
          end
        end
      end
    end
  end
end
