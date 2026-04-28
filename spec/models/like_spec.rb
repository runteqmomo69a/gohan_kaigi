require "rails_helper"

RSpec.describe Like, type: :model do
  describe "バリデーション" do
    it "有効なfactoryを持つこと" do
      expect(build(:like)).to be_valid
    end

    it "shopがないと無効になること" do
      like = build(:like, shop: nil)

      expect(like).not_to be_valid
      expect(like.errors[:shop]).to be_present
    end

    it "userがないと無効になること" do
      like = build(:like, user: nil)

      expect(like).not_to be_valid
      expect(like.errors[:user]).to be_present
    end
  end

  describe "counter_cache" do
    it "作成時にshopのlikes_countが増えること" do
      shop = create(:shop)

      expect { create(:like, shop: shop) }
        .to change { shop.reload.likes_count }.by(1)
    end

    it "削除時にshopのlikes_countが減ること" do
      like = create(:like)

      expect { like.destroy }
        .to change { like.shop.reload.likes_count }.by(-1)
    end
  end

  describe "整合性" do
    it "同じuserとshopの組み合わせはDBレベルで重複できないこと" do
      like = create(:like)

      expect {
        Like.create!(shop: like.shop, user: like.user)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
