require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "有効なfactoryを持つこと" do
      expect(build(:user)).to be_valid
    end

    it "nameが空だと無効になること" do
      user = build(:user, name: nil)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "nameが255文字以内なら有効なこと" do
      user = build(:user, name: "a" * 255)

      expect(user).to be_valid
    end

    it "nameが256文字以上だと無効になること" do
      user = build(:user, name: "a" * 256)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "emailが重複すると無効になること" do
      create(:user, email: "same@example.com")
      user = build(:user, email: "same@example.com")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "関連" do
    it "participating_eventsから参加イベントを参照できること" do
      user = create(:user)
      event = create(:event)
      create(:event_participant, user: user, event: event)

      expect(user.participating_events).to include(event)
    end

    it "liked_shopsからいいねしたshopを参照できること" do
      user = create(:user)
      shop = create(:shop)
      create(:like, user: user, shop: shop)

      expect(user.liked_shops).to include(shop)
    end
  end

  describe "dependent: :destroy" do
    it "関連するレコードも削除すること" do
      user = create(:user)
      event = create(:event, user: user)
      other_event = create(:event)
      shop = create(:shop, event: other_event, user: user)
      like_target = create(:shop)
      create(:like, user: user, shop: like_target)
      create(:event_preference, user: user, event: other_event)
      create(:event_participant, user: user, event: other_event)

      expect { user.destroy }
        .to change(Event, :count).by(-1)
        .and change(Shop, :count).by(-1)
        .and change(Like, :count).by(-1)
        .and change(EventPreference, :count).by(-1)
        .and change(EventParticipant, :count).by(-1)
    end
  end
end
