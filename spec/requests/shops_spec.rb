require "rails_helper"

RSpec.describe "Shops", type: :request do
  let(:owner) { create(:user) }
  let(:participant) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, user: owner) }

  before do
    create(:event_participant, event: event, user: owner)
    create(:event_participant, event: event, user: participant)
  end

  describe "GET /events/:event_id/shops/new" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      get new_event_shop_path(event)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "参加者は表示できること" do
      sign_in participant

      get new_event_shop_path(event)

      expect(response).to have_http_status(:ok)
    end

    it "非参加者はイベント詳細へ戻されること" do
      sign_in other_user

      get new_event_shop_path(event)

      expect(response).to redirect_to(event_path(event))
    end
  end

  describe "POST /events/:event_id/shops/fetch_name" do
    let(:success_result) { ShopNameFetcher::Result.new(name: "shop name", error: nil) }
    let(:failure_result) { ShopNameFetcher::Result.new(name: nil, error: "failed") }

    it "参加者は成功時に200で店名JSONを受け取れること" do
      sign_in participant
      allow(ShopNameFetcher).to receive(:call).and_return(success_result)

      post fetch_name_event_shops_path(event), params: { url: "https://example.com" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "name" => "shop name", "error" => nil })
    end

    it "失敗時は422でerrorを返すこと" do
      sign_in participant
      allow(ShopNameFetcher).to receive(:call).and_return(failure_result)

      post fetch_name_event_shops_path(event), params: { url: "https://example.com" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to eq({ "name" => nil, "error" => "failed" })
    end

    it "非参加者はイベント詳細へ戻されること" do
      sign_in other_user

      post fetch_name_event_shops_path(event), params: { url: "https://example.com" }

      expect(response).to redirect_to(event_path(event))
    end
  end

  describe "POST /events/:event_id/shops" do
    let(:valid_params) do
      {
        shop: {
          name: "coffee shop",
          url: "https://example.com",
          memo: "memo"
        }
      }
    end

    before do
      allow(ShopPlaceIdFetcher).to receive(:call).and_return("place-123")
      allow(ShopOgpImageFetcher).to receive(:call).and_return(
        ShopOgpImageFetcher::Result.new(image_url: "https://example.com/image.png", error: nil)
      )
    end

    it "参加者は作成できること" do
      sign_in participant

      expect {
        post event_shops_path(event), params: valid_params
      }.to change(Shop, :count).by(1)

      expect(response).to redirect_to(event_path(event))
    end

    it "sort付きでイベント詳細へ戻ること" do
      sign_in participant

      post event_shops_path(event), params: valid_params.merge(sort: "likes_count")

      expect(response).to redirect_to(event_path(event, sort: "likes_count"))
    end

    it "不正な値だと作成されず422を返すこと" do
      sign_in participant

      expect {
        post event_shops_path(event), params: { shop: valid_params[:shop].merge(name: "") }
      }.not_to change(Shop, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "非参加者は作成できないこと" do
      sign_in other_user

      expect {
        post event_shops_path(event), params: valid_params
      }.not_to change(Shop, :count)

      expect(response).to redirect_to(event_path(event))
    end

    it "非参加者でもsortを保持してイベント詳細へ戻ること" do
      sign_in other_user

      post event_shops_path(event), params: valid_params.merge(sort: "likes_count")

      expect(response).to redirect_to(event_path(event, sort: "likes_count"))
    end
  end

  describe "PATCH /events/:event_id/shops/:id" do
    let(:shop) { create(:shop, event: event, user: participant, name: "before", url: "https://before.example.com") }

    before do
      allow(ShopPlaceIdFetcher).to receive(:call).and_return("place-123")
      allow(ShopOgpImageFetcher).to receive(:call).and_return(
        ShopOgpImageFetcher::Result.new(image_url: "https://example.com/image.png", error: nil)
      )
    end

    it "所有者は更新できること" do
      sign_in participant

      patch event_shop_path(event, shop), params: { shop: { name: "after", url: "https://after.example.com", memo: "memo" } }

      expect(response).to redirect_to(event_path(event))
      expect(shop.reload.name).to eq("after")
    end

    it "sort付きでイベント詳細へ戻ること" do
      sign_in participant

      patch event_shop_path(event, shop), params: { shop: { name: "after", url: "https://after.example.com", memo: "memo" }, sort: "likes_count" }

      expect(response).to redirect_to(event_path(event, sort: "likes_count"))
    end

    it "他人は更新できないこと" do
      sign_in owner

      patch event_shop_path(event, shop), params: { shop: { name: "after" } }

      expect(response).to redirect_to(event_path(event))
      expect(shop.reload.name).to eq("before")
    end

    it "他人でもsortを保持してイベント詳細へ戻ること" do
      sign_in owner

      patch event_shop_path(event, shop), params: { shop: { name: "after" }, sort: "likes_count" }

      expect(response).to redirect_to(event_path(event, sort: "likes_count"))
    end

    it "不正な値だと更新されず422を返すこと" do
      sign_in participant

      patch event_shop_path(event, shop), params: { shop: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(shop.reload.name).to eq("before")
    end
  end

  describe "DELETE /events/:event_id/shops/:id" do
    let!(:shop) { create(:shop, event: event, user: participant) }

    it "所有者は削除できること" do
      sign_in participant

      expect {
        delete event_shop_path(event, shop)
      }.to change(Shop, :count).by(-1)

      expect(response).to redirect_to(event_path(event))
    end

    it "sort付きでイベント詳細へ戻ること" do
      sign_in participant

      delete event_shop_path(event, shop), params: { sort: "likes_count" }

      expect(response).to redirect_to(event_path(event, sort: "likes_count"))
    end

    it "他人は削除できないこと" do
      sign_in owner

      expect {
        delete event_shop_path(event, shop)
      }.not_to change(Shop, :count)

      expect(response).to redirect_to(event_path(event))
    end

    it "他人でもsortを保持してイベント詳細へ戻ること" do
      sign_in owner

      delete event_shop_path(event, shop), params: { sort: "likes_count" }

      expect(response).to redirect_to(event_path(event, sort: "likes_count"))
    end
  end
end
