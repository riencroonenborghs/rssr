# frozen_string_literal: true

class CatchAllController < ApplicationController
  layout "error"

  rescue_from ActionController::UnknownFormat, with: -> { redirect_to "/404" }
end
