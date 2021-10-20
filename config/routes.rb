Rails.application.routes.draw do
  devise_for :users

  resources :feeds, only: [:index, :search] do
    resources :entries, only: [:index, :day] do
      collection do
        get :day
      end
    end
    get "by_tag/:tag" => "feeds#by_tag", on: :collection, as: :by_tag
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
