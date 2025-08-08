Rails.application.routes.draw do
  resources :challenges, only: [ :index, :create, :destroy ]
end
