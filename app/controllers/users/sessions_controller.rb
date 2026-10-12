module Users
  # Adds JSON responses so the React sign in modal can sign in without a page load.
  class SessionsController < Devise::SessionsController
    respond_to :html, :json
  end
end
