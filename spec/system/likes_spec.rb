# frozen_string_literal: true

require "rails_helper"

RSpec.describe "いいね導線", type: :system, js: true do
  it "参加者がイベント詳細からいいねできること" do
    owner = create(:user)
    participant = create(:user)
    event = create(:event, user: owner)
    create(:event_participant, event: event, user: participant)
    shop = create(:shop, event: event, user: owner, name: "いいねカフェ")

    sign_in_for_js(participant)
    visit event_path(event)

    shop_card = shop_card_for(shop.name)

    within(shop_card) do
      expect(page).to have_link(I18n.t("views.events.shops.like"))
      expect(page).to have_content("0")
      click_link I18n.t("views.events.shops.like")
      expect(page).to have_link(I18n.t("views.events.shops.unlike"))
      expect(page).to have_content("1")
      expect(page).to have_content(I18n.t("flash.likes.create.notice"))
      click_link I18n.t("views.events.shops.unlike")
      expect(page).to have_link(I18n.t("views.events.shops.like"))
      expect(page).to have_content("0")
      expect(page).to have_content(I18n.t("flash.likes.destroy.notice"))
    end
  end
end
