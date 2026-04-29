require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  around do |example|
    original_test_mode = OmniAuth.config.test_mode
    original_mock_auth = OmniAuth.config.mock_auth[:line]

    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.test_mode = original_test_mode
    OmniAuth.config.mock_auth[:line] = original_mock_auth
  end

  describe "GET|POST /users/auth/line/callback" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "line",
        uid: "line-uid-123",
        info: OmniAuth::AuthHash::InfoHash.new(name: "line user")
      )
    end

    it "初回ログイン時はuserを作成してdashboardへ遷移すること" do
      OmniAuth.config.mock_auth[:line] = auth_hash

      expect {
        get user_line_omniauth_callback_path
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(dashboard_path)
      expect(User.last.provider).to eq("line")
    end

    it "既存userがいれば新規作成しないこと" do
      create(:user, provider: "line", uid: "line-uid-123", email: "line@example.com", name: "line user")
      OmniAuth.config.mock_auth[:line] = auth_hash

      expect {
        get user_line_omniauth_callback_path
      }.not_to change(User, :count)

      expect(response).to redirect_to(dashboard_path)
    end

    it "nameが空ならデフォルト名を使うこと" do
      auth_without_name = OmniAuth::AuthHash.new(
        provider: "line",
        uid: "line-uid-456",
        info: OmniAuth::AuthHash::InfoHash.new(name: nil)
      )
      OmniAuth.config.mock_auth[:line] = auth_without_name

      get user_line_omniauth_callback_path

      expect(User.last.name).to eq(I18n.t("defaults.line_user_name"))
    end

    it "認証失敗時はログイン画面へリダイレクトされること" do
      OmniAuth.config.mock_auth[:line] = :invalid

      get user_line_omniauth_callback_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
