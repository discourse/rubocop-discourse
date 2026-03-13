# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoSystemSpecMetadata, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "registers an offense for `type: :system` on describe" do
    expect_offense(<<~RUBY)
      describe "login", type: :system do
                        ^^^^^^^^^^^^^ Discourse/NoSystemSpecMetadata: Remove redundant `type: :system` and `system: true` metadata from `RSpec.describe`.
      end
    RUBY

    expect_correction(<<~RUBY)
      describe "login" do
      end
    RUBY
  end

  it "registers an offense for `system: true` on RSpec.describe" do
    expect_offense(<<~RUBY)
      RSpec.describe "login", system: true do
                              ^^^^^^^^^^^^ Discourse/NoSystemSpecMetadata: Remove redundant `type: :system` and `system: true` metadata from `RSpec.describe`.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe "login" do
      end
    RUBY
  end

  it "removes redundant system metadata while preserving other metadata" do
    expect_offense(<<~RUBY)
      describe "login", type: :system, retry: 2 do
                        ^^^^^^^^^^^^^ Discourse/NoSystemSpecMetadata: Remove redundant `type: :system` and `system: true` metadata from `RSpec.describe`.
      end
    RUBY

    expect_correction(<<~RUBY)
      describe "login", retry: 2 do
      end
    RUBY
  end

  it "removes both redundant system metadata entries in a single correction" do
    expect_offense(<<~RUBY)
      RSpec.describe "login", type: :system, system: true, retry: 2 do
                              ^^^^^^^^^^^^^ Discourse/NoSystemSpecMetadata: Remove redundant `type: :system` and `system: true` metadata from `RSpec.describe`.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe "login", retry: 2 do
      end
    RUBY
  end

  it "preserves multiline formatting when removing system metadata" do
    expect_offense(<<~RUBY)
      describe "login",
        type: :system,
        ^^^^^^^^^^^^^ Discourse/NoSystemSpecMetadata: Remove redundant `type: :system` and `system: true` metadata from `RSpec.describe`.
        retry: 2 do
      end
    RUBY

    expect_correction(<<~RUBY)
      describe "login",
        retry: 2 do
      end
    RUBY
  end

  it "does not register an offense for other metadata" do
    expect_no_offenses(<<~RUBY)
      describe "login", type: :request do
      end

      context "with metadata", multisite: true do
      end
    RUBY
  end
end
