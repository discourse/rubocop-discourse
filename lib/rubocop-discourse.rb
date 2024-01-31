# frozen_string_literal: true

require "rubocop"
require "active_support"
require "active_support/core_ext/string/inflections"
require_relative "rubocop/discourse"
require_relative "rubocop/discourse/inject"

RuboCop::Discourse::Inject.defaults!

require_relative "rubocop/cop/discourse_cops"
