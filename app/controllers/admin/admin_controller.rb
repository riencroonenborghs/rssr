# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :set_admin

    private

    def set_admin
      @admin = true
    end
  end
end
