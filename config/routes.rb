Rails.application.routes.draw do
  devise_for :users
  root "static_pages#top"

  resources :events, only: %i[index show new create edit update destroy]

  get "dashboard", to: "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end