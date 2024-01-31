# frozen_string_literal: true

class RequiresPluginController < BaseController
  requires_plugin "my_plugin"
  requires_login
end
