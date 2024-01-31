# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Plugins::NamespaceMethods, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when defining a method outside any namespace" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        def my_method
        ^^^^^^^^^^^^^ Discourse/Plugins/NamespaceMethods: Don’t define methods outside a class or a module.
          "my_value"
        end

        class MyClass
          def my_method
            "my_method"
          end
        end
      RUBY
    end
  end

  context "when defining a method inside a class" do
    context "when defining an instance method" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyClass
            def my_method
              "my_value"
            end
          end
        RUBY
      end
    end

    context "when defining a class method" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class MyClass
            class << self
              def my_method
                "my_value"
              end

              def another_method
                "plop"
              end
            end
          end
        RUBY
      end
    end
  end

  context "when defining a method inside a module" do
    context "when defining an instance method" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          module MyModule
            def my_method
              "my_value"
            end
          end
        RUBY
      end
    end

    context "when defining a class method" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          module MyModule
            class << self
              def my_method
                "my_value"
              end
            end
          end
        RUBY
      end
    end
  end
end
