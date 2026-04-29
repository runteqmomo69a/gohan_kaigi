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

  it "ランキングにはいいね数上位3件だけが表示されること" do
    owner = create(:user)
    viewer = create(:user)
    event = create(:event, user: owner)
    create(:event_participant, event: event, user: viewer)

    first_shop = create(:shop, event: event, user: owner, name: "1位カフェ")
    second_shop = create(:shop, event: event, user: owner, name: "2位カフェ")
    third_shop = create(:shop, event: event, user: owner, name: "3位カフェ")
    fourth_shop = create(:shop, event: event, user: owner, name: "4位カフェ")

    4.times { |index| create(:like, shop: first_shop, user: create(:user, email: "rank1_#{index}@example.com")) }
    3.times { |index| create(:like, shop: second_shop, user: create(:user, email: "rank2_#{index}@example.com")) }
    2.times { |index| create(:like, shop: third_shop, user: create(:user, email: "rank3_#{index}@example.com")) }
    create(:like, shop: fourth_shop, user: create(:user, email: "rank4@example.com"))

    sign_in_for_js(viewer)
    visit event_path(event)

    within(:xpath, "//section[.//h2[normalize-space()='#{I18n.t('views.events.ranking.title')}']]") do
      expect(page).to have_content("1位カフェ")
      expect(page).to have_content("2位カフェ")
      expect(page).to have_content("3位カフェ")
      expect(page).not_to have_content("4位カフェ")
      expect(page).to have_selector("article", count: 3)
    end
  end
end
