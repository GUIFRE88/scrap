Rails.application.routes.draw do
  devise_for :users, controllers: { 
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :profiles do
    member do
      post :rescan
    end
  end

  get '/p/:short_code', to: 'profiles#redirect', as: :short_profile

  get 'dashboard', to: 'home#dashboard', as: :dashboard

  authenticated :user do
    root 'home#dashboard', as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  namespace :api, defaults: { format: :json } do
    resources :profiles, only: [:index, :show]
  end
end
