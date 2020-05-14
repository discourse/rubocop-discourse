# frozen_string_literal: true

module RuboCop
  module Cop
    module Discourse
      # add_reference in ActiveRecord migrations is magic, and does
      # some unexpected things in the background. For example, by default
      # it adds an index at the same time, but not concurrently, which is
      # a nightmare for large tables.
      #
      # Instead, inside a disable_ddl_transaction! migration we should create
      # the new column (with any defaults and options required) and the index
      # concurrently using hand-written SQL. This also allows us to handle
      # IF NOT EXISTS cases, which enable re-runnable migrations. Also we
      # can pick a better name for the index at the same time.
      #
      # @example
      #
      # # bad
      # def up
      #   add_reference :posts, :image_upload
      # end
      #
      # # good
      # disable_ddl_transaction!
      # def up
      #   execute <<~SQL
      #     ALTER TABLE posts
      #     ADD COLUMN IF NOT EXISTS image_upload_id bigint
      #   SQL
      #
      #   execute <<~SQL
      #     CREATE INDEX CONCURRENTLY IF NOT EXISTS
      #     index_posts_on_image_upload_id ON posts USING btree (image_upload_id)
      #   SQL
      # end
      class NoAddReferenceActiveRecordMigration < Cop
        MSG = <<~MSG
          add_reference is high-risk for large tables and has too much background magic.
          Instead, write a disable_ddl_transactions! migration and write custom SQL to
          add the new column and CREATE INDEX CONCURRENTLY. Use the IF NOT EXISTS clause
          to make the migration re-runnable if it fails partway through.
        MSG

        def_node_matcher :using_add_reference?, <<-MATCHER
          (send nil? :add_reference ...)
        MATCHER

        def on_send(node)
          return if !using_add_reference?(node)
          add_offense(node, message: MSG)
        end
      end
    end
  end
end
