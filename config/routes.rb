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

  devise_scope :user do
    namespace :admin do
      get "discover" => "discover#index"
      get "discover/search" => "discover#search", as: :discover_search
      get "discover/tag/:tag" => "discover#tagged", as: :discover_tagged

      get "discover/page/:page" => "discover#index"
      get "discover/search/page/:page" => "discover#search"
      get "discover/tag/:tag/page/:page" => "discover#tagged"

      post "subscribe/:feed_id" => "subscriptions#subscribe", as: :subscribe
      
      resources :subscriptions do
        member do 
          post :visit
        end
      end
      resources :rules

      resources :entries, only: [:visit] do
        collection do
          post :visit
        end
      end
    end
  end

  root to: "feeds#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
