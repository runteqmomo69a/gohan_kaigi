require "rails_helper"

RSpec.describe "Events", type: :request do
  describe "GET /events" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      get events_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン時は自分のイベント一覧を表示できること" do
      user = create(:user)
      own_event = create(:event, user: user, title: "owned event")
      create(:event, title: "other event")
      sign_in user

      get events_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("owned event")
      expect(response.body).not_to include("other event")
    end

    it "joinedタブでは参加イベント一覧を表示できること" do
      user = create(:user)
      joined_event = create(:event, title: "joined event")
      own_event = create(:event, user: user, title: "owned event")
      create(:event_participant, event: joined_event, user: user)
      sign_in user

      get events_path, params: { tab: "joined" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("joined event")
      expect(response.body).not_to include("owned event")
    end
  end

  describe "GET /events/:id" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      event = create(:event)

      get event_path(event)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン時は詳細を表示できること" do
      user = create(:user)
      event = create(:event, title: "event detail")
      sign_in user

      get event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("event detail")
    end
  end

  describe "GET /events/join/:unique_url" do
    it "未ログインでも表示できること" do
      event = create(:event, title: "join event")

      get join_event_path(event.unique_url)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("join event")
    end
  end

  describe "POST /events" do
    let(:valid_params) do
      {
        event: {
          title: "new event",
          event_date: Date.current,
          event_time: "18:00",
          place: "tokyo",
          note: "note"
        }
      }
    end

    it "未ログイン時はログイン画面にリダイレクトされること" do
      post events_path, params: valid_params

      expect(response).to redirect_to(new_user_session_path)
    end

    it "有効な値ならイベントと参加レコードを作成すること" do
      user = create(:user)
      sign_in user

      expect {
        post events_path, params: valid_params
      }.to change(Event, :count).by(1)
        .and change(EventParticipant, :count).by(1)

      expect(response).to redirect_to(event_path(Event.last))
    end

    it "不正な値だと作成されず422を返すこと" do
      user = create(:user)
      sign_in user

      expect {
        post events_path, params: { event: valid_params[:event].merge(title: "") }
      }.not_to change(Event, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /events/:id" do
    it "作成者は更新できること" do
      user = create(:user)
      event = create(:event, user: user, title: "before")
      sign_in user

      patch event_path(event), params: { event: { title: "after" } }

      expect(response).to redirect_to(event_path(event))
      expect(event.reload.title).to eq("after")
    end

    it "他人は更新できず詳細へ戻されること" do
      owner = create(:user)
      other_user = create(:user)
      event = create(:event, user: owner, title: "before")
      sign_in other_user

      patch event_path(event), params: { event: { title: "after" } }

      expect(response).to redirect_to(event_path(event))
      expect(event.reload.title).to eq("before")
    end

    it "不正な値だと更新されず422を返すこと" do
      user = create(:user)
      event = create(:event, user: user, title: "before")
      sign_in user

      patch event_path(event), params: { event: { title: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(event.reload.title).to eq("before")
    end
  end

  describe "DELETE /events/:id" do
    it "作成者は削除できること" do
      user = create(:user)
      event = create(:event, user: user)
      sign_in user

      expect {
        delete event_path(event)
      }.to change(Event, :count).by(-1)

      expect(response).to redirect_to(events_path)
    end

    it "他人は削除できないこと" do
      owner = create(:user)
      other_user = create(:user)
      event = create(:event, user: owner)
      sign_in other_user

      expect {
        delete event_path(event)
      }.not_to change(Event, :count)

      expect(response).to redirect_to(event_path(event))
    end
  end
end
