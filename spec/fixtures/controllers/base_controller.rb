# frozen_string_literal: true

class BaseController
  class << self
    def requires_plugin(*)
    end

    def requires_login
    end
  end
end
