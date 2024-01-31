# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Plugins
        # Methods must be defined inside the plugin namespace (module or class).
        #
        # @example
        #   # bad
        #   def my_method
        #   end
        #
        #   # good
        #   module MyPlugin
        #     def my_method
        #     end
        #   end
        #
        class NamespaceMethods < Base
          MSG = "Don’t define methods outside a class or a module."

          def on_def(node)
            return if inside_namespace?(node)
            add_offense(node, message: MSG)
          end

          private

          def inside_namespace?(node)
            node.each_ancestor.detect { _1.class_type? || _1.module_type? }
          end
        end
      end
    end
  end
end
