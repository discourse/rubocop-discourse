# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoResetColumnInformationInMigrations, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  before { config["Discourse/NoResetColumnInformationInMigrations"]["Enabled"] = true }

  it "raises an offense if reset_column_information is used" do
    offenses = inspect_source(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def up
          Post.reset_column_information
        end
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end

  it "raise an offense if reset_column_information is used without AR model" do
    offenses = inspect_source(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def up
          "post".classify.constantize.reset_column_information
        end
      end
    RUBY

    expect(offenses.first.message).to match(described_class::MSG)
  end
end
