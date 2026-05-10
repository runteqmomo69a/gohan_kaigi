require "rails_helper"

RSpec.describe EventPreference, type: :model do
  describe "enum定義" do
    it "budgetの値に意味のある名前を持たせていること" do
      expect(described_class.budgets).to eq(
        "one" => 1,
        "two" => 2,
        "three" => 3,
        "four" => 4,
        "five" => 5
      )
    end
  end

  describe "バリデーション" do
    it "有効なfactoryを持つこと" do
      expect(build(:event_preference)).to be_valid
    end

    it "同じuserとeventの組み合わせは重複できないこと" do
      event_preference = create(:event_preference)
      duplicate = build(:event_preference, event: event_preference.event, user: event_preference.user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "eventがないと無効になること" do
      event_preference = build(:event_preference, event: nil)

      expect(event_preference).not_to be_valid
      expect(event_preference.errors[:event]).to be_present
    end

    it "userがないと無効になること" do
      event_preference = build(:event_preference, user: nil)

      expect(event_preference).not_to be_valid
      expect(event_preference.errors[:user]).to be_present
    end
  end

  describe "#budget_label" do
    {
      one: "one",
      two: "two",
      three: "three",
      four: "four",
      five: "five"
    }.each do |budget_value, budget_label_key|
      it "budgetが#{budget_value}のとき対応する文言を返すこと" do
        event_preference = build(:event_preference, budget: budget_value)

        expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.#{budget_label_key}"))
      end
    end

    it "想定外の値なら未設定文言を返すこと" do
      event_preference = build(:event_preference, budget: nil)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.unset"))
    end
  end
end
