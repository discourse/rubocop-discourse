# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoMixingMultisiteAndStandardSpecs, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "raises an offense if there are multisite and standard top-level describes" do
    offenses = inspect_source(<<~RUBY)
      RSpec.describe "test" do
      end

      describe "test2", type: :multisite do
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "raises an offense if there are multiple multisite and standard top-level describes" do
    offenses = inspect_source(<<~RUBY)
      describe "test", type: :multisite do
      end

      describe "test2", type: :multisite do
      end

      describe "test2" do
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "does not raise an offense if there are only multisite describes" do
    offenses = inspect_source(<<~RUBY)
      require "foo"

      describe "test", type: :multisite do
        describe "inner-test" do
          it "test" do
          end
        end
      end

      RSpec.describe "test2", type: :multisite do
      end
    RUBY

    expect(offenses).to eq([])
  end

  it "does not raise an offense if there are only standard describes" do
    offenses = inspect_source(<<~RUBY)
      require "rails_helper"

      describe "test" do
      end

      describe "test2" do
        RSpec.describe "inner-test" do
        end
      end
    RUBY

    expect(offenses).to eq([])
  end
end
