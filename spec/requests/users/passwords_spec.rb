require "rails_helper"

RSpec.describe "Users::Passwords", type: :request do
  describe "GET /users/password/new" do
    it "未ログイン時は表示できること" do
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

  describe "GET /users/password/edit" do
    it "ログイン済みならdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      get edit_user_password_path, params: { reset_password_token: "token" }

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
