# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Plugins::UsePluginInstanceOn, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when outside `plugin.rb`" do
    context "when `DiscourseEvent.on` is called" do
      it "registers an offense" do
        expect_offense(<<~RUBY, "another_file.rb")
          DiscourseEvent.on(:topic_status_updated) { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/UsePluginInstanceOn: Don’t call `DiscourseEvent.on` outside `plugin.rb`.
        RUBY
      end
    end
  end

  context "when inside `plugin.rb`" do
    context "when `DiscourseEvent.on` is called" do
      it "registers an offense" do
        expect_offense(<<~RUBY, "plugin.rb")
          DiscourseEvent.on(:topic_status_updated) { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/UsePluginInstanceOn: Use `on` instead of `DiscourseEvent.on` [...]
        RUBY
      end
    end

    context "when `on` is called" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY, "plugin.rb")
          on(:topic_status_updated) { do_something }
        RUBY
      end
    end
  end
end
