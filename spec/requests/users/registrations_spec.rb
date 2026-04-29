require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/sign_up" do
    it "未ログイン時は表示できること" do
      get new_user_registration_path

      expect(response).to have_http_status(:ok)
    end

    it "ログイン済みならdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      get new_user_registration_path

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "GET /users/edit" do
    it "ログイン済みでもdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      get edit_user_registration_path

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "PATCH /users" do
    it "ログイン済みでもdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      patch user_registration_path, params: { user: { name: "updated" } }

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "DELETE /users" do
    it "ログイン済みでもdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      delete user_registration_path

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
