require "rails_helper"

RSpec.describe EventParticipant, type: :model do
  describe "バリデーション" do
    it "有効なfactoryを持つこと" do
      expect(build(:event_participant)).to be_valid
    end

    it "同じuserとeventの組み合わせは重複できないこと" do
      event_participant = create(:event_participant)
      duplicate = build(:event_participant, event: event_participant.event, user: event_participant.user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "eventがないと無効になること" do
      event_participant = build(:event_participant, event: nil)

      expect(event_participant).not_to be_valid
      expect(event_participant.errors[:event]).to be_present
    end

    it "userがないと無効になること" do
      event_participant = build(:event_participant, user: nil)

      expect(event_participant).not_to be_valid
      expect(event_participant.errors[:user]).to be_present
    end
  end
end
