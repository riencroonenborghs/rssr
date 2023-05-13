require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :users

  resources :feeds, only: [:index, :search] do
    resources :entries, only: [:index, :day] do
      collection do
        get :today
      end
    end
    get "tagged/:tag" => "feeds#tagged", on: :collection, as: :tagged
    get "tagged/:tag/today" => "feeds#tagged_today", on: :collection, as: :tagged_today
  end

  get "tags" => "tags#index", as: :tags

  get "today" => "subscriptions#today", as: :subscriptions_today
  get "yesterday" => "subscriptions#yesterday", as: :subscriptions_yesterday

  devise_scope :user do
    authenticated :user do
      mount Sidekiq::Web => '/sidekiq'
    end
    
    post "viewed/:entry_id" => "viewed_entries#create"

    get "bookmarks" => "bookmarks#index", as: :all_bookmarks
    post "bookmarks/:entry_id" => "bookmarks#create", as: :add_bookmark
    delete "bookmarks/:entry_id" => "bookmarks#destroy", as: :remove_bookmark

    get "watches" => "watches#index", as: :watches
    get "watches/group/:group_id" => "watches#show", as: :watches_group
    

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
    end
  end

  root to: "subscriptions#today"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
