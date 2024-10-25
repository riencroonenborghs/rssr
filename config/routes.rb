require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :users

  resources :feeds, only: [:search] do
    resources :entries, only: [:index] do
    end
    get "tagged/:tag" => "feeds#tagged", on: :collection, as: :tagged
    get "tagged/entries/:tag" => "feeds#entry_tagged", on: :collection, as: :entry_tagged
  end

  get "search" => "searches#new", as: :new_search
  post "search" => "searches#results", as: :search

  resources "subscriptions", only: [:index]

  devise_scope :user do
    authenticated :user do
      mount Sidekiq::Web => '/sidekiq'
    end
    
    post "viewed/:entry_id" => "viewed_entries#create"
    get "/feeds/:feed_id/entries/:id" => "entries#show", as: :view_entry
    post "/feeds/:feed_id/entries/:id/send-to-downloader" => "entries#send_to_downloader", as: :send_to_downloader

    get "bookmarks" => "bookmarks#index", as: :all_bookmarks
    post "bookmarks/:entry_id" => "bookmarks#create", as: :add_bookmark
    delete "bookmarks/:entry_id" => "bookmarks#destroy", as: :remove_bookmark

    post "notifications/:id/ack" => "notifications#ack", as: :ack_notification

    namespace :admin do
      post "subscribe/:feed_id" => "subscriptions#subscribe", as: :subscribe
      post "unsubscribe/:subscription_id" => "subscriptions#unsubscribe", as: :unsubscribe
      
      resources :subscriptions, only: [:index, :new, :edit, :update, :refresh, :create, :step_1, :step_2, :search] do
        collection do
          get :refresh_all
          get :search
          post :step_1
          post :step_2
        end
        member do
          get :toggle_active
          get :refresh
        end
      end

      resources :filters
      resources :watches, only: [:index, :new, :create, :edit, :update, :destroy]
      get "watches/group/:group_id/add" => "watches#add_to_group", as: :add_to_watch_group
      get "watches/group/:group_id/edit" => "watches#edit_group", as: :edit_watch_group
      delete "watches/group/:group_id/remove" => "watches#remove_group", as: :remove_watch_group
      get "watches/group/:group_id" => "watches#show", as: :watches_group
      get "watches/group/:group_id/copy" => "watches#copy", as: :copy_watch_group
    end
  end

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  root to: "subscriptions#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
