Rails.application.routes.draw do
  # Healthcheck pour monitoring / load balancers
  get "up" => "rails/health#show", as: :rails_health_check
  devise_for :users

  resources :challenges

  root "challenges#index"
end
