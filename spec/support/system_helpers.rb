# frozen_string_literal: true

module SystemHelpers
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"
    click_button I18n.t("views.devise.sessions.new.submit")
  end

  def sign_in_for_js(user)
    login_as(user, scope: :user)
  end

  def shop_card_for(name)
    find(:xpath, "//article[.//h3[normalize-space()='#{name}']]", match: :first)
  end
end
