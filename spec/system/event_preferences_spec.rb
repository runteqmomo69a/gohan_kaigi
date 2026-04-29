# frozen_string_literal: true

require "rails_helper"

RSpec.describe "希望条件投稿導線", type: :system, js: true do
  it "参加者が希望条件を入力して保存できること" do
    owner = create(:user)
    participant = create(:user)
    event = create(:event, user: owner)
    create(:event_participant, event: event, user: participant)

    sign_in_for_js(participant)
    visit event_path(event)

    find("label", text: I18n.t("views.events.preferences.open_form")).click

    fill_in "event_preference_dislike_foods", with: "パクチー"
    select I18n.t("views.events.preferences.option_3"), from: "event_preference_budget"
    fill_in "event_preference_content", with: "落ち着いたお店が良い"

    within(".modal-box", text: I18n.t("views.events.preferences.open_form")) do
      click_button I18n.t("common.save")
    end

    expect(page).to have_content("パクチー")
    expect(page).to have_content(I18n.t("views.events.preferences.option_3"))
    expect(page).to have_content("落ち着いたお店が良い")
  end
end
