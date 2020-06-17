# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "rubocop-discourse"
  s.version     = "2.1.3"
  s.summary     = "Custom rubocop cops used by Discourse"
  s.authors     = ["David Taylor"]
  s.files       = `git ls-files`.split($/)
  s.license       = "MIT"
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rubocop", ">= 0.69.0"
  s.add_runtime_dependency "rubocop-rspec", ">= 1.39.0"

  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec"
end
