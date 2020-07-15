# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Discourse::NoMockingJobs, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new
  end

  it "raises an offense if Jobs is mocked" do
    inspect_source(<<~RUBY)
    Jobs.expects(:enqueue)
    RUBY

    expect(cop.offenses.first.message).to eq(described_class::MSG)
  end

  it "does not raise an offense if Jobs is not mocked" do
    inspect_source(<<~RUBY)
    Jobs.enqueue(:some_job)
    RUBY

    expect(cop.offenses).to eq([])
  end
end
