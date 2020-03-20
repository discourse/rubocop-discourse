# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "rubocop-discourse"
  s.version     = "1.0.2"
  s.summary     = "Custom rubocop cops used by Discourse"
  s.authors     = ["David Taylor"]
  s.files       = ["lib/rubocop-discourse.rb", "lib/rubocop/cop/discourse_cops.rb"]
  s.license       = "MIT"
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rubocop", ">= 0.69.0"
end
