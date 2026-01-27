Rails.application.routes.draw do
  devise_for :users, controllers: { 
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  get 'dashboard', to: 'home#dashboard', as: :dashboard
  
  authenticated :user do
    root 'home#dashboard', as: :authenticated_root
  end
  
  unauthenticated do
    devise_scope :user do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
