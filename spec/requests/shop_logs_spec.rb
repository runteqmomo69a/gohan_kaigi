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

    it "% を含む文字列でもそのまま検索できること" do
      create(:shop, event: event, user: user, name: "100% cafe")
      create(:shop, event: event, user: user, name: "1000 cafe")

      sign_in user

      get shop_logs_path, params: { q: "%" }

      expect(response.body).to include("100% cafe")
      expect(response.body).not_to include("1000 cafe")
    end

    it "_ を含む文字列でもそのまま検索できること" do
      create(:shop, event: event, user: user, name: "ramen_house")
      create(:shop, event: event, user: user, name: "ramen house")

      sign_in user

      get shop_logs_path, params: { q: "_" }

      expect(response.body).to include("ramen_house")
      expect(response.body).not_to include("ramen house")
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

    it "一致候補が6件以上あっても最大5件まで返すこと" do
      sign_in user

      6.times do |index|
        create(:shop, event: event, user: user, name: "coffee_#{index}")
      end

      get shop_logs_autocomplete_path, params: { q: "coffee" }

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(result.size).to eq(5)
      expect(result).to all(include("coffee"))
    end

    it "% を含む文字列でもそのまま候補検索できること" do
      create(:shop, event: event, user: user, name: "100% cafe")
      create(:shop, event: event, user: user, name: "1000 cafe")

      sign_in user

      get shop_logs_autocomplete_path, params: { q: "%" }

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(result).to include("100% cafe")
      expect(result).not_to include("1000 cafe")
    end

    it "_ を含む文字列でもそのまま候補検索できること" do
      create(:shop, event: event, user: user, name: "ramen_house")
      create(:shop, event: event, user: user, name: "ramen house")

      sign_in user

      get shop_logs_autocomplete_path, params: { q: "_" }

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(result).to include("ramen_house")
      expect(result).not_to include("ramen house")
    end
  end

  describe "PATCH /shop_logs/:id" do
    it "自分のshop logを更新できること" do
      sign_in user

      patch shop_log_path(shop1), params: { shop: { log_category: "dessert", log_note: "updated" } }

      expect(response).to redirect_to(shop_logs_path)
      expect(shop1.reload.log_category).to eq("dessert")
    end

    it "検索条件付き一覧へ戻ること" do
      sign_in user

      patch shop_log_path(shop1), params: {
        shop: { log_category: "dessert", log_note: "updated" },
        q: "coffee",
        category: "cafe",
        sort: "old"
      }

      expect(response).to redirect_to(shop_logs_path(q: "coffee", category: "cafe", sort: "old"))
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
