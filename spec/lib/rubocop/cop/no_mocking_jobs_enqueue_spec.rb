# frozen_string_literal: true

require "spec_helper"

describe RuboCop::Cop::Discourse::NoMockingJobs, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "raises an offense if Jobs is mocked with :enqueue" do
    offenses = inspect_source(<<~RUBY)
    Jobs.expects(:enqueue)
    RUBY

    expect(offenses.first.message).to end_with(described_class::MSG)
  end

  it "raises an offense if Jobs is mocked with :enqueue_in" do
    offenses = inspect_source(<<~RUBY)
    Jobs.expects(:enqueue_in)
    RUBY

    expect(offenses.first.message).to end_with(described_class::MSG)
  end

  it "does not raise an offense if Jobs is not mocked with :enqueue or :enqueue_in" do
    offenses = inspect_source(<<~RUBY)
    Jobs.enqueue(:some_job)
    RUBY

    expect(offenses).to eq([])
  end
end
