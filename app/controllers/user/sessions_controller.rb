# frozen_string_literal: true

module User
  class SessionsController < Devise::SessionsController
    layout "devise"
  end
end
