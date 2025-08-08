Rails.application.routes.draw do
  devise_for :users

  resources :challenges

  root "challenges#index"
end
