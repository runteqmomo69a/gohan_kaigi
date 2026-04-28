require "rails_helper"

RSpec.describe "ShopLogs", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, user: user) }
  let!(:shop1) { create(:shop, event: event, user: user, name: "coffee", log_category: "cafe", log_note: "note1") }
  let!(:shop2) { create(:shop, event: event, user: user, name: "ramen", log_category: "noodle", log_note: "note2", created_at: 1.day.ago) }

  describe "GET /shop_logs" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      get shop_logs_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン時は表示できること" do
      sign_in user

      get shop_logs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("coffee")
      expect(response.body).to include("ramen")
    end

    it "qで検索できること" do
      sign_in user

      get shop_logs_path, params: { q: "coffee" }

      expect(response.body).to include("coffee")
      expect(response.body).not_to include("ramen")
    end

    it "categoryで絞り込みできること" do
      sign_in user

      get shop_logs_path, params: { category: "cafe" }

      expect(response.body).to include("coffee")
      expect(response.body).not_to include("ramen")
    end
  end

  describe "GET /shop_logs/autocomplete" do
    it "未ログイン時はリダイレクトされること" do
      get shop_logs_autocomplete_path, params: { q: "co" }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン時は一致する店名配列を返すこと" do
      sign_in user

      get shop_logs_autocomplete_path, params: { q: "co" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([ "coffee" ])
    end
  end

  describe "PATCH /shop_logs/:id" do
    it "自分のshop logを更新できること" do
      sign_in user

      patch shop_log_path(shop1), params: { shop: { log_category: "dessert", log_note: "updated" } }

      expect(response).to redirect_to(shop_logs_path)
      expect(shop1.reload.log_category).to eq("dessert")
    end

    it "不正な値だと422を返すこと" do
      sign_in user

      patch shop_log_path(shop1), params: { shop: { log_note: "a" * 1001 } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "他人のshop logは更新できないこと" do
      sign_in other_user

      patch shop_log_path(shop1), params: { shop: { log_category: "dessert" } }

      expect(response).to have_http_status(:not_found)
    end
  end
end
