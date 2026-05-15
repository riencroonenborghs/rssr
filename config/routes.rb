# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # mount Sidekiq::Web => "/sidekiq" if Rails.env.development?

  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  scope "/v2" do
    get "/", to: "react_app#index", as: :react_app
    get "/bookmarks", to: "react_app#index"
    get "/feeds/:feed_id", to: "react_app#index"
    get "/feeds/:feed_id/entries/:entry_id", to: "react_app#index"
    get "/tags/:tag_id", to: "react_app#index"
    get "/reports/:report_id", to: "react_app#index"
    get "/reports/:report_id/daily/:daily_id", to: "react_app#index"
  end

  # resources :unread, only: [:index]
  # resources :feeds, only: [:show] do
  #   resources :entries, only: [:show]
  # end
  # resources :tags, only: [:show]

  devise_scope :user do
    authenticated :user do
      mount Sidekiq::Web => "/sidekiq"
  #     resources :bookmarks, only: [:index, :create, :destroy]
  #     resources :subscriptions, only: [:index, :new, :create, :destroy]
  #     resources :filters, only: [:index, :new, :create, :destroy]
  #     resources :search, only: [:new, :create]
  #     resources :generated_reports, only: [:show]
    end
  end
  
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: "api/v1/users/sessions"
      }

      resources :unread, only: [:index]
      resources :feeds, only: [:index, :show] do
        resources :entries, only: [:show]
      end
      resources :tags, only: [:show]
      resources :bookmarks, only: [:index, :create, :destroy]

      resources :subscriptions, only: [:index, :create, :destroy]
      resources :reports, only: [:index, :create, :update, :destroy] do
        resources :daily, only: [:index, :show], controller: "reports/daily"
      end

      resources :filters, only: [:index, :create, :destroy]
    end
  end

  match "/:code", to: "errors#show", via: :all, constraints: { code: Regexp.new(
 ErrorsController::VALID_STATUS_CODES.join("|") ) }
  
  match "*path", to: "catch_all#show", via: :all

  root to: "react_app#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end