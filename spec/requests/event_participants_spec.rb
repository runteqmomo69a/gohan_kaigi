require "rails_helper"

RSpec.describe "EventParticipants", type: :request do
  let(:event) { create(:event) }

  describe "POST /events/:event_id/event_participants" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      post event_event_participants_path(event)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みなら参加できること" do
      user = create(:user)
      sign_in user

      expect {
        post event_event_participants_path(event)
      }.to change(EventParticipant, :count).by(1)

      expect(response).to redirect_to(event_path(event))
    end

    it "重複参加時は件数が増えないこと" do
      user = create(:user)
      create(:event_participant, event: event, user: user)
      sign_in user

      expect {
        post event_event_participants_path(event)
      }.not_to change(EventParticipant, :count)

      expect(response).to redirect_to(event_path(event))
    end
  end
end
