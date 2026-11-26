# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      class NoTlsVerificationBypass < Base
        MSG = "Do not disable TLS certificate or hostname verification."

        def_node_matcher :verify_none?, <<~PATTERN
          (const (const (const {nil? cbase} :OpenSSL) :SSL) :VERIFY_NONE)
        PATTERN

        def_node_matcher :comparison?, <<~PATTERN
          (send _ {:== :!= :equal? :eql?} _)
        PATTERN

        def_node_matcher :disabling_option?, <<~PATTERN
          (pair (sym {:verify :verify_peer :ssl_verify_peer :verify_hostname}) false)
        PATTERN

        def_node_matcher :disabling_assignment?, <<~PATTERN
          {
            (send _ :verify_hostname= false)
            (send _ :[]= (sym {:verify :verify_peer :ssl_verify_peer :verify_hostname}) false)
          }
        PATTERN

        def on_const(node)
          return if !verify_none?(node)
          return if node.parent && comparison?(node.parent)

          add_offense(node)
        end

        def on_pair(node)
          add_offense(node) if disabling_option?(node)
        end

        def on_send(node)
          add_offense(node) if disabling_assignment?(node)
        end
        alias on_csend on_send
      end
    end
  end
end
