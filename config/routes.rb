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

    get "read_later" => "read_later_entries#index", as: :read_later_all
    post "read_later/:entry_id" => "read_later_entries#create", as: :read_later
    delete "read_later/:entry_id/read_it" => "read_later_entries#destroy", as: :read_later_read_it

    namespace :admin do
      get "discover" => "discover#index"
      get "discover/search" => "discover#search", as: :discover_search
      get "discover/tag/:tag" => "discover#tagged", as: :discover_tagged

      get "discover/page/:page" => "discover#index"
      get "discover/search/page/:page" => "discover#search"
      get "discover/tag/:tag/page/:page" => "discover#tagged"

      post "subscribe/:feed_id" => "subscriptions#subscribe", as: :subscribe
      post "unsubscribe/:subscription_id" => "subscriptions#unsubscribe", as: :unsubscribe
      
      resources :subscriptions, only: [:index, :new, :sync, :create] do
        collection do
          get :sync
        end
        member do
          get :toggle_active
        end
      end

      resources :rules

      # resources :entries, only: [:visit] do
      #   collection do
      #     get :visit
      #   end
      # end
    end
  end

  root to: "subscriptions#today"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
