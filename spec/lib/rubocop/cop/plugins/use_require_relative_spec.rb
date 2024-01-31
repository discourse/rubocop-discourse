# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Plugins::UseRequireRelative, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when using `load`" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        load File.expand_path("../app/jobs/onceoff/voting_ensure_consistency.rb", __FILE__)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/UseRequireRelative: Use `require_relative` instead of `load`.
      RUBY
    end
  end

  context "when using `require_relative`" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        require_relative "app/controllers/encrypt_controller.rb"
      RUBY
    end
  end
end
