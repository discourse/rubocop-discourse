# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Services::EmptyLinesAroundBlocks,
               :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when not in a service class" do
    it "does nothing" do
      expect_no_offenses(<<~RUBY)
        class NotAService
          step :first_step
          params do
            attribute :my_attribute
          end
          step :another_step
        end
      RUBY
    end
  end

  context "when in a service class" do
    context "when a blank line is missing before a block" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            step :first_step
            params do
            ^^^^^^^^^ Discourse/Services/EmptyLinesAroundBlocks: Add empty lines around a step block.
              attribute :my_attribute
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            step :first_step

            params do
              attribute :my_attribute
            end
          end
        RUBY
      end
    end

    context "when a blank line is missing after a block" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            params do
            ^^^^^^^^^ Discourse/Services/EmptyLinesAroundBlocks: Add empty lines around a step block.
              attribute :my_attribute
            end
            step :last_step
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            params do
              attribute :my_attribute
            end

            step :last_step
          end
        RUBY
      end
    end

    context "when two blocks are next to each other" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            params do
            ^^^^^^^^^ Discourse/Services/EmptyLinesAroundBlocks: Add empty lines around a step block.
              attribute :attribute
              validates :attribute, presence: true
            end
            transaction do
            ^^^^^^^^^^^^^^ Discourse/Services/EmptyLinesAroundBlocks: Add empty lines around a step block.
              step :first
              step :second
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            params do
              attribute :attribute
              validates :attribute, presence: true
            end

            transaction do
              step :first
              step :second
            end
          end
        RUBY
      end
    end

    context "when a block is a one-liner" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            try { step :might_raise }
            step :last_step
          end
        RUBY
      end
    end

    context "when blocks are nested" do
      context "when the nested block is in the first position" do
        context "when there is no empty line before" do
          it "does not register an offense" do
            expect_no_offenses(<<~RUBY)
              class MyService
                include Service::Base

                transaction do
                  try do
                    step :first_step
                    step :second_step
                  end

                  step :third_step
                end
              end
            RUBY
          end
        end

        context "when there is no empty line after" do
          it "registers an offense" do
            expect_offense(<<~RUBY)
              class MyService
                include Service::Base

                transaction do
                  try do
                  ^^^^^^ Discourse/Services/EmptyLinesAroundBlocks: Add empty lines around a step block.
                    step :first_step
                    step :second_step
                  end
                  step :third_step
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class MyService
                include Service::Base

                transaction do
                  try do
                    step :first_step
                    step :second_step
                  end

                  step :third_step
                end
              end
            RUBY
          end
        end
      end

      context "when the nested block is in the last position" do
        context "when there is no empty line after" do
          it "does not register an offense" do
            expect_no_offenses(<<~RUBY)
              class MyService
                include Service::Base

                transaction do
                  step :first_step

                  try do
                    step :second_step
                    step :third_step
                  end
                end
              end
            RUBY
          end
        end

        context "when there is no empty line before" do
          it "registers an offense" do
            expect_offense(<<~RUBY)
              class MyService
                include Service::Base

                transaction do
                  step :first_step
                  try do
                  ^^^^^^ Discourse/Services/EmptyLinesAroundBlocks: Add empty lines around a step block.
                    step :second_step
                    step :third_step
                  end
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class MyService
                include Service::Base

                transaction do
                  step :first_step

                  try do
                    step :second_step
                    step :third_step
                  end
                end
              end
            RUBY
          end
        end
      end
    end

    context "when blocks are used in methods" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            step :first_step

            def first_step(model:)
              model.transaction do
                do_something
              end
            end
          end
        RUBY
      end
    end

    context "with a full valid example" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            step :first_step

            params do
              attribute :my_attribute

              validates :my_attributes, presence: true
            end

            policy :allowed?
            model :user

            transaction do
              try do
                step :save_user
                step :log
              end

              step :other_step
            end

            step :last_step
          end
        RUBY
      end
    end
  end
end
