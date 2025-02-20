# frozen_string_literal: true

require "rubocop"
require "lint_roller"
require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"
require_relative "rubocop/cop/discourse_cops"
require_relative "rubocop/discourse/version"
require_relative "rubocop/discourse/plugin"
