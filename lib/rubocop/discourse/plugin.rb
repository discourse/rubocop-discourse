# frozen_string_literal: true

module RuboCop
  module Discourse
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rubocop-discourse",
          version: RuboCop::Discourse::VERSION,
          homepage: "https://github.com/discourse/rubocop-discourse",
          description: "Custom rubocop cops used by Discourse",
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join("../../../config/default.yml"),
        )
      end
    end
  end
end
