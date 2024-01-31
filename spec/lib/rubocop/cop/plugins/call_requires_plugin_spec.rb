# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Plugins::CallRequiresPlugin, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when `requires_plugin` is missing" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class MyController < ApplicationController
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/CallRequiresPlugin: Use `requires_plugin` in controllers to prevent routes from being accessible when plugin is disabled.
          requires_login
        end
      RUBY
    end
  end

  context "when `requires_plugin` is not missing" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class MyController
          requires_plugin MyPlugin::PLUGIN_NAME
          requires_login
        end
      RUBY
    end
  end

  context "when inheriting" do
    let(:controllers_path) do
      Pathname.new("#{__dir__}/../../../../fixtures/controllers").cleanpath
    end

    before do
      # As we’re providing real files, we need to get rid of the default config
      # restricting the cop to `app/controllers/*`
      configuration.for_cop(cop).delete("Include")
    end

    context "when `requires_plugin` is called in a parent controller" do
      let(:good_controller) { controllers_path.join("good_controller.rb") }

      it "does not register an offense" do
        expect_no_offenses(good_controller.read, good_controller.to_s)
      end
    end

    context "when `requires_plugin` is not called in a parent controller" do
      let(:bad_controller) { controllers_path.join("bad_controller.rb") }

      it "registers an offense" do
        expect_offense(bad_controller.read, bad_controller.to_s)
      end
    end

    context "when parent controller can’t be located" do
      context "when parent controller is namespaced" do
        let(:controller) do
          controllers_path.join("namespaced_parent_controller.rb")
        end

        it "registers an offense" do
          expect_offense(controller.read, controller.to_s)
        end
      end

      context "when parent controller is not namespaced" do
        let(:controller) do
          controllers_path.join("inherit_from_outside_controller.rb")
        end

        it "registers an offense" do
          expect_offense(controller.read, controller.to_s)
        end
      end
    end
  end
end
