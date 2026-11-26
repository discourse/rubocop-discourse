# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      class NoNetHttpSettingsInStartBlock < Base
        MSG =
          "`%<setting>s` set inside the `start` block only applies to reconnections. " \
            "Pass it as an option to `start` instead."

        CONNECTION_SETTINGS = %i[
          ca_file=
          ca_path=
          cert=
          cert_store=
          ciphers=
          extra_chain_cert=
          ipaddr=
          key=
          local_host=
          local_port=
          max_version=
          min_version=
          open_timeout=
          ssl_timeout=
          ssl_version=
          use_ssl=
          verify_callback=
          verify_depth=
          verify_hostname=
          verify_mode=
        ].to_set.freeze

        def_node_matcher :http_start_block, <<~PATTERN
          (block
            (send {(const _ :HTTP) (send (const _ :HTTP) :new ...)} :start ...)
            (args (arg $_) ...)
            $_)
        PATTERN

        def on_block(node)
          http_start_block(node) do |http, body|
            body&.each_node(:send) do |send_node|
              next if !CONNECTION_SETTINGS.include?(send_node.method_name)
              next if !send_node.receiver&.lvar_type?
              next if send_node.receiver.children.first != http

              add_offense(
                send_node,
                message: format(MSG, setting: send_node.method_name.to_s.delete_suffix("=")),
              )
            end
          end
        end
      end
    end
  end
end
