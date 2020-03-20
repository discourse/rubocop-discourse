# frozen_string_literal: true

path = File.join(__dir__, "rubocop", "cop", "discourse", "*.rb")
Dir[path].each { |file| require file }
