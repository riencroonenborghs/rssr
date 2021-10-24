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
      resources :feeds do
        member do 
          post :visit
        end
      end

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
