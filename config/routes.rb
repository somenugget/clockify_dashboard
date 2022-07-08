Rails.application.routes.draw do
  root "times#index"

  resource :auth, only: [:show, :create]
  resources :times, only: [:index]
end
