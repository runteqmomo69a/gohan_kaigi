# frozen_string_literal: true

require "rails_helper"

RSpec.describe "イベント導線", type: :system do
  it "ログインしてイベントを作成し、詳細画面へ遷移できること" do
    user = create(:user)

    sign_in_as(user)
    within("article", text: I18n.t("views.dashboard.cards.events_new_title")) do
      click_link I18n.t("views.dashboard.cards.events_new_link")
    end

    fill_in "event_title", with: "金曜ランチ会"
    fill_in "event_event_date", with: Date.current.strftime("%Y-%m-%d")
    fill_in "event_event_time", with: "18:30"
    fill_in "event_place", with: "新宿"
    fill_in "event_note", with: "駅近で集まりたい"

    expect do
      click_button I18n.t("common.create")
    end.to change(Event, :count).by(1)
      .and change(EventParticipant, :count).by(1)

    event = Event.order(:created_at).last

    expect(page).to have_current_path(event_path(event), ignore_query: true)
    expect(page).to have_content("金曜ランチ会")
    expect(page).to have_content("新宿")
    expect(page).to have_content(user.name)
  end

  it "イベント作成者には編集・削除ボタンが表示されること" do
    owner = create(:user)
    event = create(:event, user: owner, title: "作成者イベント")
    create(:event_participant, event: event, user: owner)

    sign_in_as(owner)
    visit event_path(event)

    expect(page).to have_link(I18n.t("common.edit"))
    expect(page).to have_link(I18n.t("common.delete"))
  end

  it "他のユーザーには編集・削除ボタンが表示されないこと" do
    owner = create(:user)
    other_user = create(:user)
    event = create(:event, user: owner, title: "他人イベント")
    create(:event_participant, event: event, user: other_user)

    sign_in_as(other_user)
    visit event_path(event)

    expect(page).not_to have_link(I18n.t("common.edit"))
    expect(page).not_to have_link(I18n.t("common.delete"))
  end
end
