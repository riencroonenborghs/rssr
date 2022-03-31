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
  resources :search, only: [:new, :create]


  get "today" => "subscriptions#today", as: :subscriptions_today

  devise_scope :user do
    authenticated :user do
      mount Sidekiq::Web => '/sidekiq'
    end
    
    post "viewed/:entry_id" => "viewed_entries#create"

    get "bookmarks" => "bookmarks#index", as: :all_bookmarks
    post "bookmarks/:entry_id" => "bookmarks#create", as: :add_bookmark
    delete "bookmarks/:entry_id" => "bookmarks#destroy", as: :remove_bookmark

    namespace :admin do
      post "subscribe/:feed_id" => "subscriptions#subscribe", as: :subscribe
      post "unsubscribe/:subscription_id" => "subscriptions#unsubscribe", as: :unsubscribe
      
      resources :subscriptions, only: [:index, :new, :sync, :create, :search] do
        collection do
          get :sync
          get :search
        end
        member do
          get :toggle_active
        end
      end

      resources :filters
    end
  end

  root to: "subscriptions#today"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
