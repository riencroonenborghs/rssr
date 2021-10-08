Rails.application.routes.draw do
  devise_for :users

  # resources :entries, only: [:index]
  # resources :feeds, only: [:entries] do
  #   member do
  #     get :entries
  #   end
  # end

  resources :feeds, only: [:index] do
    resources :entries, only: [:index]
  end

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
