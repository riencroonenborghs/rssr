# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }

  # The job queue dashboard, for signed in users only.
  authenticate :user do
    mount SolidQueueMonitor::Engine => "/solid_queue"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  namespace :api, defaults: { format: :json } do
    resources :bookmarks, only: :index
    resources :subscriptions, only: [ :index, :create, :destroy ] do
      resource :reload, only: :create, controller: "subscription_reloads"
    end
    resources :filters, only: [ :index, :create, :destroy ]
    resource :search, only: :show
    resource :summary, only: :create
    resources :feeds, only: :index do
      resources :entries, only: :index
    end
    resources :entries, only: [ :index, :show ] do
      resource :read, only: :create
      resource :bookmark, only: [ :create, :destroy ], controller: "entry_bookmarks"
    end
  end

  # Client-side routes of the React app; each serves the app, which renders the page.
  %w[feeds bookmarks search summary subscriptions filters settings].each do |path|
    get path, to: "home#index"
  end
  get "feeds/:feed_id(/entries/:entry_id)", to: "home#index"
  get "entries/:entry_id", to: "home#index"
  get "bookmarks/entries/:entry_id", to: "home#index"
  get "search/entries/:entry_id", to: "home#index"
end
