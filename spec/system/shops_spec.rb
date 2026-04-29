# frozen_string_literal: true

require "rails_helper"

RSpec.describe "お店候補登録導線", type: :system do
  before do
    allow_any_instance_of(Shop).to receive(:fetch_place_id).and_return("place-123")
    allow(ShopOgpImageFetcher).to receive(:call).and_return(
      ShopOgpImageFetcher::Result.new(image_url: "https://example.com/shop.png", error: nil)
    )
  end

  it "イベント参加者がお店候補を登録して詳細画面に表示できること" do
    owner = create(:user)
    participant = create(:user)
    event = create(:event, user: owner, title: "候補登録イベント")
    create(:event_participant, event: event, user: participant)

    sign_in_as(participant)
    visit event_path(event)
    click_link I18n.t("views.events.shops.new_shop")

    fill_in "shop_url", with: "https://example.com/cafe"
    fill_in "shop_name", with: "テストカフェ"
    fill_in "shop_memo", with: "プリンが人気"

    expect do
      click_button I18n.t("common.create")
    end.to change(Shop, :count).by(1)

    expect(page).to have_current_path(event_path(event), ignore_query: true)
    expect(page).to have_content("テストカフェ")
    expect(page).to have_content("プリンが人気")
  end

  it "お店候補の登録者には編集・削除ボタンが表示されること" do
    owner = create(:user)
    participant = create(:user)
    event = create(:event, user: owner)
    create(:event_participant, event: event, user: participant)
    shop = create(:shop, event: event, user: participant, name: "編集確認カフェ")

    sign_in_as(participant)
    visit event_path(event)

    shop_card = shop_card_for(shop.name)

    within(shop_card) do
      expect(page).to have_link(I18n.t("common.edit"))
      expect(page).to have_link(I18n.t("common.delete"))
    end
  end

  it "他の参加者には編集・削除ボタンが表示されないこと" do
    owner = create(:user)
    shop_owner = create(:user)
    other_user = create(:user)
    event = create(:event, user: owner)
    create(:event_participant, event: event, user: shop_owner)
    create(:event_participant, event: event, user: other_user)
    shop = create(:shop, event: event, user: shop_owner, name: "権限確認カフェ")

    sign_in_as(other_user)
    visit event_path(event)

    shop_card = shop_card_for(shop.name)

    within(shop_card) do
      expect(page).not_to have_link(I18n.t("common.edit"))
      expect(page).not_to have_link(I18n.t("common.delete"))
    end
  end
end
