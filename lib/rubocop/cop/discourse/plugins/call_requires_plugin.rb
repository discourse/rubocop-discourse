# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Plugins
        # Plugin controllers must call `requires_plugin` to prevent routes from
        # being accessible when the plugin is disabled.
        #
        # @example
        #   # bad
        #   class MyController
        #     def my_action
        #     end
        #   end
        #
        #   # good
        #   class MyController
        #     requires_plugin PLUGIN_NAME
        #     def my_action
        #     end
        #   end
        #
        class CallRequiresPlugin < Base
          MSG =
            "Use `requires_plugin` in controllers to prevent routes from being accessible when plugin is disabled."

          def_node_matcher :requires_plugin_present?, <<~MATCHER
            (class _ _
              {
                (begin <(send nil? :requires_plugin _) ...>)
                <(send nil? :requires_plugin _) ...>
              }
            )
          MATCHER

          def on_class(node)
            return if requires_plugin_present?(node)
            return if requires_plugin_present_in_parent_classes(node)
            add_offense(node, message: MSG)
          end

          private

          def requires_plugin_present_in_parent_classes(node)
            return unless processed_source.path
            controller_path =
              base_controller_path(node.parent_class&.const_name.to_s)
            return unless controller_path
            Commissioner
              .new([self.class.new(config, @options)])
              .investigate(parse(controller_path.read, controller_path.to_s))
              .offenses
              .empty?
          end

          def base_controller_path(base_class)
            return if base_class.blank?
            base_path = "#{base_class.underscore}.rb"
            path = Pathname.new("#{processed_source.path}/../").cleanpath
            until path.root?
              controller_path = path.join(base_path)
              return controller_path if controller_path.exist?
              path = path.join("..").cleanpath
            end
          end
        end
      end
    end
  end
end
