# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      class NoMockingJobs < Cop
        MSG = "Use the test helpers provided by Sidekiq instead of mocking `Jobs`."

        def_node_matcher :mocking_jobs?, <<~MATCHER
        (send (const nil? :Jobs) :expects ...)
        MATCHER

        def on_send(node)
          return unless mocking_jobs?(node)
          add_offense(node, message: MSG)
        end
      end
    end
  end
end
