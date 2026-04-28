require "rails_helper"

RSpec.describe "StaticPages", type: :request do
  it "トップページを表示できること" do
    get root_path

    expect(response).to have_http_status(:ok)
  end

  it "利用規約ページを表示できること" do
    get terms_path

    expect(response).to have_http_status(:ok)
  end

  it "プライバシーポリシーページを表示できること" do
    get privacy_path

    expect(response).to have_http_status(:ok)
  end
end
