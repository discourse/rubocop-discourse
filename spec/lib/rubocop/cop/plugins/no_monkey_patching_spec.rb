# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Discourse::Plugins::NoMonkeyPatching, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when outside `plugin.rb`" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "my_class.rb")
        class ::MyClass
          def my_method
            "my_value"
          end
        end

        class AnotherClass
          def my_method
            "my_value"
          end
        end
      RUBY
    end
  end

  context "when inside `plugin.rb`" do
    context "when opening an existing class" do
      it "registers an offense" do
        expect_offense(<<~RUBY, "plugin.rb")
          after_initialize do
            module MyPlugin
              class Engine < Rails::Engine
                isolate_namespace MyPlugin
              end
            end

            class ::Topic
            ^^^^^^^^^^^^^ Discourse/Plugins/NoMonkeyPatching: Don’t reopen existing classes. [...]
              def self.new_method
                :new_value
              end

              def my_new_method
                "my_new_value"
              end
            end
          end
        RUBY
      end
    end

    context "when opening an existing serializer" do
      it "registers an offense" do
        expect_offense(<<~RUBY, "plugin.rb")
          class ::TopicSerializer
          ^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/NoMonkeyPatching: Don’t reopen serializers. [...]
            def new_attribute
              "my_attribute"
            end
          end
        RUBY
      end
    end

    context "when calling `.class_eval` on a class" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          User.class_eval do
          ^^^^^^^^^^^^^^^ Discourse/Plugins/NoMonkeyPatching: Don’t call `class_eval`. [...]
            def a_new_method
              :new_value
            end
          end
        RUBY
      end
    end

    context "when calling `.class_eval` on a serializer" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          UserSerializer.class_eval do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/Plugins/NoMonkeyPatching: Don’t call `class_eval` on a serializer. [...]
            def a_new_method
              :new_value
            end
          end
        RUBY
      end
    end
  end
end
