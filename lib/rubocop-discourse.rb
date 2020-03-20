# frozen_string_literal: true

path = File.join(__dir__, "rubocop", "cop", "discourse_cops", "*.rb")
Dir[path].each { |file| require file }
