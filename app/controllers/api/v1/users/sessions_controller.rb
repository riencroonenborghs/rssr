# frozen_string_literal: true

module Api
  module V1
    class Users::SessionsController < Devise::SessionsController
      respond_to :html, :json

      skip_before_action :verify_authenticity_token

      def create
        super do |resource|
          if request.format.json?
            if resource.persisted?
              return render json: { id: resource.id, email: resource.email }, status: :ok
            else
              return render json: { error: "Invalid email or password." }, status: :unauthorized
            end
          end
        end
      end

      private

      def auth_options
        { scope: :user, recall: "api/v1/users/sessions#new", locale: :en }
      end
    end
  end
end
