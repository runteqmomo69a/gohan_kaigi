Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  root "static_pages#top"
  
  get "terms",   to: "static_pages#terms"
  get "privacy", to: "static_pages#privacy"

  resources :events, only: %i[index show new create edit update destroy] do
    resources :event_participants, only: [:create]
    
    resources :event_preferences, only: [:create, :destroy]
    
    resources :shops, only: %i[new create edit update destroy] do
      resource :like, only: %i[create destroy]
    end
  end
  
  resources :shop_logs, only: [:index, :edit, :update]
  
  get "shop_logs/autocomplete", to: "shop_logs#autocomplete"

  get "/events/join/:unique_url", to: "events#join", as: "join_event"
  
  get "dashboard", to: "dashboard#index"

  # 開発環境だけ、送信メール確認ページを有効化
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  get "up" => "rails/health#show", as: :rails_health_check
end