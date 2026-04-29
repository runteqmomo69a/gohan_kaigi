# frozen_string_literal: true

require "rails_helper"

RSpec.describe "イベント参加導線", type: :system do
  it "共有URLからログインしてイベントに参加できること" do
    user = create(:user)
    event = create(:event, title: "共有イベント")

    visit join_event_path(event.unique_url)

    expect(page).to have_content("共有イベント")
    click_link I18n.t("views.events.join.login_button")

    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"
    click_button I18n.t("views.devise.sessions.new.submit")

    expect(page).to have_current_path(join_event_path(event.unique_url), ignore_query: true)

    expect do
      click_button I18n.t("views.events.join.join_button")
    end.to change(EventParticipant, :count).by(1)

    expect(page).to have_current_path(event_path(event), ignore_query: true)
    expect(page).to have_content(I18n.t("views.events.show.joined"))
    expect(page).to have_link(I18n.t("views.events.shops.new_shop"))
  end
end
