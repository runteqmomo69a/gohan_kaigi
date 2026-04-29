require "rails_helper"

RSpec.describe "EventPreferences", type: :request do
  let(:owner) { create(:user) }
  let(:participant) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, user: owner) }

  before do
    create(:event_participant, event: event, user: owner)
    create(:event_participant, event: event, user: participant)
  end

  describe "POST /events/:event_id/event_preferences" do
    let(:valid_params) do
      {
        event_preference: {
          dislike_foods: "none",
          budget: 3,
          content: "memo"
        }
      }
    end

    it "未ログイン時はログイン画面にリダイレクトされること" do
      post event_event_preferences_path(event), params: valid_params

      expect(response).to redirect_to(new_user_session_path)
    end

    it "参加者は作成できること" do
      sign_in participant

      expect {
        post event_event_preferences_path(event), params: valid_params
      }.to change(EventPreference, :count).by(1)

      expect(response).to redirect_to(event_path(event))
    end

    it "既存レコードがある場合は更新され件数は増えないこと" do
      preference = create(:event_preference, event: event, user: participant, content: "before")
      sign_in participant

      expect {
        post event_event_preferences_path(event), params: { event_preference: { content: "after", budget: 4 } }
      }.not_to change(EventPreference, :count)

      expect(response).to redirect_to(event_path(event))
      expect(preference.reload.content).to eq("after")
    end

    it "非参加者は投稿できないこと" do
      sign_in other_user

      expect {
        post event_event_preferences_path(event), params: valid_params
      }.not_to change(EventPreference, :count)

      expect(response).to redirect_to(event_path(event))
    end

    it "保存失敗時は422でイベント詳細を再描画すること" do
      sign_in participant
      allow_any_instance_of(EventPreference).to receive(:update).and_return(false)

      expect {
        post event_event_preferences_path(event), params: valid_params
      }.not_to change(EventPreference, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(event.title)
      expect(response.body).to include(I18n.t("views.events.preferences.open_form"))
    end
  end

  describe "DELETE /events/:event_id/event_preferences/:id" do
    let!(:preference) { create(:event_preference, event: event, user: participant) }

    it "自分の希望条件を削除できること" do
      sign_in participant

      expect {
        delete event_event_preference_path(event, preference)
      }.to change(EventPreference, :count).by(-1)

      expect(response).to redirect_to(event_path(event))
    end

    it "自分の希望条件がなくても安全にイベント詳細へ戻ること" do
      sign_in owner

      expect {
        delete event_event_preference_path(event, 0)
      }.not_to change(EventPreference, :count)

      expect(response).to redirect_to(event_path(event))
    end
  end
end
