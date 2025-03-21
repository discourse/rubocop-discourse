# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::OnlyTopLevelMultisiteSpecs, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "raises an offense if multisite config option is used in a sub-describe" do
    offenses = inspect_source(<<~RUBY)
      describe "test" do
        describe "sub-test", type: :multisite do
        end
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "raises an offense if multisite config option is used in a sub-describe (RSpec const version)" do
    offenses = inspect_source(<<~RUBY)
      RSpec.describe "test" do
        RSpec.describe "sub-test", type: :multisite do
        end
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "raises an offense if multisite config option is used in an example" do
    offenses = inspect_source(<<~RUBY)
      describe "test" do
        it "acts as an example" do
        end

        it "does a thing", type: :multisite do
        end
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "raises an offense if multisite config option is used in a context" do
    offenses = inspect_source(<<~RUBY)
      describe "test" do
        context "special circumstances", type: :multisite do
        end
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "does not raise an offense if multisite config option is used on top-level describe" do
    offenses = inspect_source(<<~RUBY)
      describe "test", type: :multisite do
        describe "sub-test" do
        end
      end
    RUBY

    expect(offenses).to eq([])
  end

  it "does not raise an offense if multisite config option is used on top-level describe (RSpec const version)" do
    offenses = inspect_source(<<~RUBY)
      require "rails_helper"

      RSpec.describe "test", type: :multisite do
        describe "sub-test" do
        end
      end
    RUBY

    expect(offenses).to eq([])
  end
end
