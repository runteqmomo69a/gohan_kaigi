require "rails_helper"

RSpec.describe EventPreference, type: :model do
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
    it "budgetが1のとき対応する文言を返すこと" do
      event_preference = build(:event_preference, budget: 1)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.one"))
    end

    it "budgetが2のとき対応する文言を返すこと" do
      event_preference = build(:event_preference, budget: 2)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.two"))
    end

    it "budgetが3のとき対応する文言を返すこと" do
      event_preference = build(:event_preference, budget: 3)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.three"))
    end

    it "budgetが4のとき対応する文言を返すこと" do
      event_preference = build(:event_preference, budget: 4)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.four"))
    end

    it "budgetが5のとき対応する文言を返すこと" do
      event_preference = build(:event_preference, budget: 5)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.five"))
    end

    it "想定外の値なら未設定文言を返すこと" do
      event_preference = build(:event_preference, budget: nil)

      expect(event_preference.budget_label).to eq(I18n.t("models.event_preference.budget_labels.unset"))
    end
  end
end
