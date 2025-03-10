# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)
require "rubocop/discourse/version"

Gem::Specification.new do |s|
  s.name = "rubocop-discourse"
  s.version = RuboCop::Discourse::VERSION
  s.summary = "Custom rubocop cops used by Discourse"
  s.authors = ["Discourse Team"]
  s.license = "MIT"
  s.homepage = "https://github.com/discourse/rubocop-discourse"

  s.files = `git ls-files`.split($/)
  s.require_paths = ["lib"]
  s.metadata["default_lint_roller_plugin"] = "RuboCop::Discourse::Plugin"

  s.add_runtime_dependency "activesupport", ">= 6.1"
  s.add_runtime_dependency "rubocop", ">= 1.73.2"
  s.add_runtime_dependency "rubocop-rspec", ">= 3.0.1"
  s.add_runtime_dependency "rubocop-factory_bot", ">= 2.27.0"
  s.add_runtime_dependency "rubocop-capybara", ">= 2.22.0"
  s.add_runtime_dependency "rubocop-rails", ">= 2.30.3"
  s.add_runtime_dependency "rubocop-rspec_rails", ">= 2.31.0"
  s.add_runtime_dependency "lint_roller", ">= 1.1.0"

  s.add_development_dependency "rake", "~> 13.1.0"
  s.add_development_dependency "rspec", "~> 3.12.0"
end
