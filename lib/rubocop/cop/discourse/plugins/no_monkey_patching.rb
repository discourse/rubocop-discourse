# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Plugins
        # Don’t monkey-patch classes directly in `plugin.rb`. Instead, define
        # additional methods in a dedicated mixin (an ActiveSupport concern for
        # example) and use `prepend` (this allows calling `super` from the mixin).
        #
        # If you’re just adding new methods to an existing serializer, then use
        # `add_to_serializer` instead.
        #
        # @example generic monkey-patching
        #   # bad
        #   ::Topic.class_eval do
        #     has_many :new_items
        #
        #     def new_method
        #     end
        #   end
        #
        #   # good
        #   module MyPlugin::TopicExtension
        #     extend ActiveSupport::Concern
        #
        #     prepended do
        #       has_many :new_items
        #     end
        #
        #     def new_method
        #     end
        #   end
        #
        #   reloadable_patch { ::Topic.prepend(MyPlugin::TopicExtension) }
        #
        # @example for serializers
        #   # bad
        #   UserSerializer.class_eval do
        #     def new_method
        #       do_processing
        #     end
        #   end
        #
        #   # good
        #   add_to_serializer(:user, :new_method) { do_processing }
        #
        class NoMonkeyPatching < Base
          MSG =
            "Don’t reopen existing classes. Instead, create a mixin and use `prepend`."
          MSG_CLASS_EVAL =
            "Don’t call `class_eval`. Instead, create a mixin and use `prepend`."
          MSG_CLASS_EVAL_SERIALIZERS =
            "Don’t call `class_eval` on a serializer. If you’re adding new methods, use `add_to_serializer`. Otherwise, create a mixin and use `prepend`."
          MSG_SERIALIZERS =
            "Don’t reopen serializers. Instead, use `add_to_serializer`."
          RESTRICT_ON_SEND = [:class_eval].freeze

          def_node_matcher :existing_class?, <<~MATCHER
            (class (const (cbase) _) ...)
          MATCHER

          def_node_matcher :serializer?, <<~MATCHER
            ({class send} (const _ /Serializer$/) ...)
          MATCHER

          def on_send(node)
            if serializer?(node)
              return add_offense(node, message: MSG_CLASS_EVAL_SERIALIZERS)
            end
            add_offense(node, message: MSG_CLASS_EVAL)
          end

          def on_class(node)
            return unless in_plugin_rb_file?
            return unless existing_class?(node)
            if serializer?(node)
              return add_offense(node, message: MSG_SERIALIZERS)
            end
            add_offense(node, message: MSG)
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
