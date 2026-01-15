Rails.application.routes.draw do
  get 'user_sessions/new'
  get 'users/new'
  get 'users/create'
  root "static_pages#top"

  resources :users, only: %i[new create]

  get    "login",  to: "user_sessions#new"
  post   "login",  to: "user_sessions#create"
  delete "logout", to: "user_sessions#destroy"

  get "up" => "rails/health#show", as: :rails_health_check
end
