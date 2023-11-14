# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout "error"

  def not_found
    # Rollbar.error(request.env["action_dispatch.exception"])
    render status: 404
  end

  def internal_server_error
    Rollbar.error(request.env["action_dispatch.exception"])
    render status: 500
  end
end
