require "rails_helper"

RSpec.describe "Likes", type: :request do
  let(:owner) { create(:user) }
  let(:participant) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, user: owner) }
  let(:shop) { create(:shop, event: event, user: owner) }

  before do
    create(:event_participant, event: event, user: owner)
    create(:event_participant, event: event, user: participant)
  end

  describe "POST /events/:event_id/shops/:shop_id/like" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      post event_shop_like_path(event, shop)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "参加者はいいねできること" do
      sign_in participant

      expect {
        post event_shop_like_path(event, shop)
      }.to change(Like, :count).by(1)

      expect(response).to redirect_to(event_path(event))
    end

    it "非参加者はいいねできないこと" do
      sign_in other_user

      expect {
        post event_shop_like_path(event, shop)
      }.not_to change(Like, :count)

      expect(response).to redirect_to(event_path(event))
    end
  end

  describe "DELETE /events/:event_id/shops/:shop_id/like" do
    let!(:like) { create(:like, user: participant, shop: shop) }

    it "参加者はいいね解除できること" do
      sign_in participant

      expect {
        delete event_shop_like_path(event, shop)
      }.to change(Like, :count).by(-1)

      expect(response).to redirect_to(event_path(event))
    end
  end
end
