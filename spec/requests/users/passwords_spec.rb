require "rails_helper"

RSpec.describe "Users::Passwords", type: :request do
  describe "GET /users/password/new" do
    it "未ログイン時は画面を表示できること" do
      get new_user_password_path

      expect(response).to have_http_status(:ok)
    end

    it "ログイン済みならdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      get new_user_password_path

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "POST /users/password" do
    it "未ログイン時でもメール送信処理を開始できること" do
      post user_password_path, params: { user: { email: "test@example.com" } }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe "GET /users/password/edit" do
    it "未ログイン時でもトークン付きなら画面を表示できること" do
      get edit_user_password_path, params: { reset_password_token: "token" }

      expect(response).to have_http_status(:ok)
    end

    it "ログイン済みならdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      get edit_user_password_path, params: { reset_password_token: "token" }

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
