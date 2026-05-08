require "rails_helper"

RSpec.describe Shop, type: :model do
  describe "バリデーション" do
    it "有効なfactoryを持つこと" do
      expect(build(:shop)).to be_valid
    end

    it "nameが空だと無効になること" do
      shop = build(:shop, name: nil)

      expect(shop).not_to be_valid
      expect(shop.errors[:name]).to be_present
    end

    it "log_noteが1000文字以内なら有効なこと" do
      shop = build(:shop, log_note: "a" * 1000)

      expect(shop).to be_valid
    end

    it "log_noteが1001文字以上だと無効になること" do
      shop = build(:shop, log_note: "a" * 1001)

      expect(shop).not_to be_valid
      expect(shop.errors[:log_note]).to be_present
    end

    it "eventがないと無効になること" do
      shop = build(:shop, event: nil, user: build(:user))

      expect(shop).not_to be_valid
      expect(shop.errors[:event]).to be_present
    end

    it "userがないと無効になること" do
      shop = build(:shop, user: nil)

      expect(shop).not_to be_valid
      expect(shop.errors[:user]).to be_present
    end
end

  describe "関連" do
    it "liked_usersからいいねしたuserを参照できること" do
      shop = create(:shop)
      user = create(:user)
      create(:like, shop: shop, user: user)

      expect(shop.liked_users).to include(user)
    end

    it "likes_countの初期値が0であること" do
      shop = create(:shop)

      expect(shop.likes_count).to eq(0)
    end
  end

  describe "dependent: :destroy" do
    it "関連するlikesを削除すること" do
      shop = create(:shop)
      create(:like, shop: shop)

      expect { shop.destroy }.to change(Like, :count).by(-1)
    end
  end

  describe "#map_query" do
    it "event_placeがある場合は店名と結合すること" do
      shop = build(:shop, name: "coffee")

      expect(shop.map_query("shinjuku")).to eq("coffee shinjuku")
    end

    it "event_placeがない場合は店名だけ返すこと" do
      shop = build(:shop, name: "coffee")

      expect(shop.map_query).to eq("coffee")
    end

    it "店名だけあれば店名を返すこと" do
      shop = build(:shop, name: "coffee")

      expect(shop.map_query(nil)).to eq("coffee")
    end
  end

  describe "#map_embed_url" do
    it "place_idがある場合はGoogle Maps embed URLを返すこと" do
      shop = build(:shop, name: "coffee", place_id: "place-123")
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("GOOGLE_MAPS_API_KEY", nil).and_return("test-key")

      expect(shop.map_embed_url("shinjuku")).to eq(
        "https://www.google.com/maps/embed/v1/place?key=test-key&q=place_id:place-123"
      )
    end

    it "place_idがない場合は店名ベースのURLを返すこと" do
      shop = build(:shop, name: "coffee", place_id: nil)

      expect(shop.map_embed_url("shinjuku")).to eq(
        "https://www.google.com/maps?q=coffee+shinjuku&output=embed"
      )
    end
  end

  describe "#map_link_url" do
    it "Google Mapsの検索URLを返すこと" do
      shop = build(:shop, name: "coffee")

      expect(shop.map_link_url("shinjuku")).to eq(
        "https://www.google.com/maps/search/?api=1&query=coffee+shinjuku"
      )
    end
  end
end
