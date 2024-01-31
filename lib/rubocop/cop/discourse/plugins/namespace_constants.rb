# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      module Plugins
        # Constants must be defined inside the plugin namespace (module or class).
        #
        # @example
        #   # bad
        #   MY_CONSTANT = :value
        #
        #   # good
        #   module MyPlugin
        #     MY_CONSTANT = :value
        #   end
        #
        class NamespaceConstants < Base
          MSG = "Don’t define constants outside a class or a module."

          def on_casgn(node)
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
