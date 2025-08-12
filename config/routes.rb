Rails.application.routes.draw do
  devise_for :users
  root 'challenges#index'

  resources :challenges do
    member do
      post :participate
      delete :leave
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
