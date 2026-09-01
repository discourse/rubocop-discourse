# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::PrivateDeclaration, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "accepts private constants declared one at a time after their definitions" do
    expect_no_offenses(<<~RUBY)
      class Example
        FIRST = "first"
        private_constant :FIRST

        SECOND = "second"
        private_constant :SECOND
      end
    RUBY
  end

  it "rejects a private constant declaration with multiple names" do
    expect_offense(<<~RUBY)
      class Example
        FIRST = "first"
        SECOND = "second"
        private_constant :FIRST, :SECOND
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/PrivateDeclaration: Pass one name to `private_constant` and place it immediately after its definition.
      end
    RUBY
  end

  it "rejects a private constant declaration separated from its definition" do
    expect_offense(<<~RUBY)
      class Example
        FIRST = "first"
        do_something
        private_constant :FIRST
        ^^^^^^^^^^^^^^^^^^^^^^^ Discourse/PrivateDeclaration: Pass one name to `private_constant` and place it immediately after its definition.
      end
    RUBY
  end

  it "rejects a private constant declaration after a different definition" do
    expect_offense(<<~RUBY)
      class Example
        FIRST = "first"
        SECOND = "second"
        private_constant :FIRST
        ^^^^^^^^^^^^^^^^^^^^^^^ Discourse/PrivateDeclaration: Pass one name to `private_constant` and place it immediately after its definition.
      end
    RUBY
  end

  it "rejects a private constant declaration after a namespaced definition" do
    expect_offense(<<~RUBY)
      class Example
        Other::FIRST = "first"
        private_constant :FIRST
        ^^^^^^^^^^^^^^^^^^^^^^^ Discourse/PrivateDeclaration: Pass one name to `private_constant` and place it immediately after its definition.
      end
    RUBY
  end

  it "rejects dynamic private declarations" do
    expect_offense(<<~RUBY)
      class Example
        FIRST = "first"
        private_constant *NAMES
        ^^^^^^^^^^^^^^^^^^^^^^^ Discourse/PrivateDeclaration: Pass one name to `private_constant` and place it immediately after its definition.
      end
    RUBY
  end
end
