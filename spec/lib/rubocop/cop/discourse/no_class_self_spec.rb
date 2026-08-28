# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoClassSelf, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "rejects class self blocks containing methods" do
    expect_offense(<<~RUBY)
      class Example
        class << self
        ^^^^^^^^^^^^^ Discourse/NoClassSelf: Do not use `class << self`.
          def call
          end
        end
      end
    RUBY
  end

  it "rejects class self blocks without method definitions" do
    expect_offense(<<~RUBY)
      class Example
        class << self
        ^^^^^^^^^^^^^ Discourse/NoClassSelf: Do not use `class << self`.
          attr_reader :value
        end
      end
    RUBY
  end

  it "accepts singleton class blocks for other objects" do
    expect_no_offenses(<<~RUBY)
      class << object
        def call
        end
      end
    RUBY
  end
end
