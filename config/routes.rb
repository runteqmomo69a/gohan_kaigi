Rails.application.routes.draw do
  devise_for :users
  root "static_pages#top"

  resources :events, only: %i[index show new create edit update destroy]
  get "dashboard", to: "dashboard#index"

  # 開発環境だけ、送信メール確認ページを有効化
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  get "up" => "rails/health#show", as: :rails_health_check
end