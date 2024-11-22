# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Services::GroupKeywords, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when not in a service class" do
    it "does nothing" do
      expect_no_offenses(<<~RUBY)
        class NotAService
          step :first_step

          step :another_step
        end
      RUBY
    end
  end

  context "when in a service class" do
    context "when keywords are not grouped together" do
      it "reports an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            model :user
            ^^^^^^^^^^^ Discourse/Services/GroupKeywords: Group one-liner steps together by removing extra empty lines.

            policy :allowed?
            step :save
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            model :user
            policy :allowed?
            step :save
          end
        RUBY
      end
    end

    context "when a one-liner block has an empty line before a keyword" do
      it "reports an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            model :user
            policy :allowed?
            ^^^^^^^^^^^^^^^^ Discourse/Services/GroupKeywords: Group one-liner steps together by removing extra empty lines.

            try { step :save }
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            model :user
            policy :allowed?
            try { step :save }
          end
        RUBY
      end
    end

    context "when keywords with empty lines appear in a nested block" do
      it "reports an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            transaction do
              step :save
              ^^^^^^^^^^ Discourse/Services/GroupKeywords: Group one-liner steps together by removing extra empty lines.

              step :log
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            transaction do
              step :save
              step :log
            end
          end
        RUBY
      end
    end

    context "when keywords are grouped together" do
      it "does not report an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            model :user
            policy :allowed?

            transaction do
              step :save
              step :log
            end
          end
        RUBY
      end
    end

    context "when keywords are not at the top level" do
      it "does not report an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            private

            def my_method
              step(:save)

              step(:log)
            end
          end
        RUBY
      end
    end
  end
end
