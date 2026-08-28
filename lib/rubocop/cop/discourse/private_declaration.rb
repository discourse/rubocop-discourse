# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      class PrivateDeclaration < Base
        MSG = "Pass one name to `%<declaration>s` and place it immediately after its definition."
        RESTRICT_ON_SEND = %i[private_class_method private_constant].freeze

        def on_send(node)
          return if valid_declaration?(node)

          add_offense(node, message: format(MSG, declaration: node.method_name))
        end

        private

        def valid_declaration?(node)
          return false unless node.arguments.one?

          name = literal_name(node.first_argument)
          return false unless name

          matching_definition?(node.method_name, node.left_sibling, name)
        end

        def literal_name(argument)
          argument.value.to_sym if argument&.type?(:sym, :str)
        end

        def matching_definition?(declaration, definition, name)
          case declaration
          when :private_constant
            definition&.casgn_type? && definition.children.first.nil? && definition.name == name
          when :private_class_method
            definition&.defs_type? && definition.receiver.self_type? &&
              definition.method_name == name
          end
        end
      end
    end
  end
end
