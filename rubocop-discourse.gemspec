# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "rubocop-discourse"
  s.version = "3.8.0"
  s.summary = "Custom rubocop cops used by Discourse"
  s.authors = ["Discourse Team"]
  s.license = "MIT"
  s.homepage = "https://github.com/discourse/rubocop-discourse"

  s.files = `git ls-files`.split($/)
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activesupport", ">= 6.1"
  s.add_runtime_dependency "rubocop", ">= 1.59.0"
  s.add_runtime_dependency "rubocop-rspec", ">= 2.25.0"
  s.add_runtime_dependency "rubocop-factory_bot", ">= 2.0.0"
  s.add_runtime_dependency "rubocop-capybara", ">= 2.0.0"
  s.add_runtime_dependency "rubocop-rails", ">= 2.25.0"

  s.add_development_dependency "rake", "~> 13.1.0"
  s.add_development_dependency "rspec", "~> 3.12.0"
end
