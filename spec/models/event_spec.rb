require "rails_helper"

RSpec.describe Event, type: :model do
  describe "バリデーション" do
    it "有効なfactoryを持つこと" do
      expect(build(:event)).to be_valid
    end

    it "titleが空だと無効になること" do
      event = build(:event, title: nil)

      expect(event).not_to be_valid
      expect(event.errors[:title]).to be_present
    end

    it "event_dateが空だと無効になること" do
      event = build(:event, event_date: nil)

      expect(event).not_to be_valid
      expect(event.errors[:event_date]).to be_present
    end

    it "unique_urlが重複すると無効になること" do
      create(:event, unique_url: "same-url")
      event = build(:event, unique_url: "same-url")

      expect(event).not_to be_valid
      expect(event.errors[:unique_url]).to be_present
    end

    it "noteが1000文字以内なら有効なこと" do
      event = build(:event, note: "a" * 1000)

      expect(event).to be_valid
    end

    it "noteが1001文字以上だと無効になること" do
      event = build(:event, note: "a" * 1001)

      expect(event).not_to be_valid
      expect(event.errors[:note]).to be_present
    end

    it "titleが255文字以内なら有効なこと" do
      event = build(:event, title: "a" * 255)

      expect(event).to be_valid
    end

    it "titleが256文字以上だと無効になること" do
      event = build(:event, title: "a" * 256)

      expect(event).not_to be_valid
      expect(event.errors[:title]).to be_present
    end

    it "unique_urlが255文字以内なら有効なこと" do
      event = build(:event, unique_url: "a" * 255)

      expect(event).to be_valid
    end

    it "unique_urlが256文字以上だと無効になること" do
      event = build(:event, unique_url: "a" * 256)

      expect(event).not_to be_valid
      expect(event.errors[:unique_url]).to be_present
    end

    it "noteが空でも有効なこと" do
      event = build(:event, note: "")

      expect(event).to be_valid
    end
  end

  describe "関連" do
    it "participantsから参加者を参照できること" do
      event = create(:event)
      user = create(:user)
      create(:event_participant, event: event, user: user)

      expect(event.participants).to include(user)
    end
  end

  describe "コールバック" do
    it "作成時にunique_urlを自動生成すること" do
      event = create(:event, unique_url: nil)

      expect(event.unique_url).to be_present
    end

    it "unique_urlがある場合はその値を維持すること" do
      event = create(:event, unique_url: "custom-url")

      expect(event.unique_url).to eq("custom-url")
    end
  end

  describe "dependent: :destroy" do
    it "関連するレコードも削除すること" do
      event = create(:event)
      participant = create(:event_participant, event: event)
      shop = create(:shop, event: event)
      preference = create(:event_preference, event: event)

      expect { event.destroy }
        .to change(EventParticipant, :count).by(-1)
        .and change(Shop, :count).by(-1)
        .and change(EventPreference, :count).by(-1)
    end
  end
end
