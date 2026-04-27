# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::Services::MutableAttributeDefault, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when not in a service class" do
    it "does nothing" do
      expect_no_offenses(<<~RUBY)
        class NotAService
          attribute :foo, default: {}
          attribute :bar, default: []
        end
      RUBY
    end
  end

  context "when in a service class" do
    context "with a hash literal default" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            options do
              attribute :overrides, default: {}
                                             ^^ Discourse/Services/MutableAttributeDefault: Mutable `default: {}` is shared across all instances; wrap it in a proc: `-> { {} }`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            options do
              attribute :overrides, default: -> { {} }
            end
          end
        RUBY
      end
    end

    context "with an array literal default and no type" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class MyService
            include Service::Base

            options do
              attribute :ids, default: [1, 2]
                                       ^^^^^^ Discourse/Services/MutableAttributeDefault: Mutable `default: [1, 2]` is shared across all instances; wrap it in a proc: `-> { [1, 2] }`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyService
            include Service::Base

            options do
              attribute :ids, default: -> { [1, 2] }
            end
          end
        RUBY
      end
    end

    context "with `:array` cast type and an array default" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            options do
              attribute :tags, :array, default: []
              attribute :seeds, :array, default: [1, 2]
            end
          end
        RUBY
      end
    end

    context "without a default kwarg" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyService
            include Service::Base

            params do
              attribute :foo
              attribute :bar, :string
            end
          end
        RUBY
      end
    end
  end
end
