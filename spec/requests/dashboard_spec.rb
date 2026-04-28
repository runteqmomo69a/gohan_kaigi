require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /dashboard" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      get dashboard_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン時は表示できること" do
      user = create(:user)
      sign_in user

      get dashboard_path

      expect(response).to have_http_status(:ok)
    end
  end
end
