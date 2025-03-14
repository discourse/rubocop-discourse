# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::TimeEqMatcher, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "raises an offense if a timestamp is compared using `eq`" do
    offenses = inspect_source(<<~RUBY)
    expect(user.created_at).to eq(Time.zone.now)
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "passes if a timestamp is compared using `eq_time`" do
    offenses = inspect_source(<<~RUBY)
      expect(user.created_at).to eq_time(Time.zone.now)
    RUBY

    expect(offenses).to be_empty
  end
end
