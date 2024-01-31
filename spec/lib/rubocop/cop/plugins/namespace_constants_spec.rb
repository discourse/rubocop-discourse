# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Plugins::NamespaceConstants, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when defining a constant outside any namespace" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        MY_CONSTANT = "my_value"
        ^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/NamespaceConstants: Don’t define constants outside a class or a module.

        class MyClass
          MY_CONSTANT = "my_value"
        end
      RUBY
    end
  end

  context "when defining a constant inside a class" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class MyClass
          MY_CONSTANT = "my_value"
        end
      RUBY
    end
  end

  context "when defining a constant inside a module" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        module MyModule
          MY_CONSTANT = "my_value"
        end
      RUBY
    end
  end
end
