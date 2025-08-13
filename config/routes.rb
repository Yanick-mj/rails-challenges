Rails.application.routes.draw do
  # Healthcheck pour monitoring / load balancers
  get "up" => "rails/health#show", as: :rails_health_check
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  resources :challenges do
    member do
      post :participate
      delete :leave
    end
  end

  root "challenges#index"
end
