require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  describe "GET /users/sign_in" do
    it "未ログイン時は表示できること" do
      get new_user_session_path

      expect(response).to have_http_status(:ok)
    end

    it "ログイン済みならdashboardへリダイレクトされること" do
      user = create(:user)
      sign_in user

      get new_user_session_path

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
