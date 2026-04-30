class Users::PasswordsController < Devise::PasswordsController
  before_action :redirect_if_authenticated, only: %i[new edit]
  before_action :redirect_unreleased_password_reset, only: %i[new create edit update]

  private

  def redirect_if_authenticated
    return unless user_signed_in?

    redirect_to dashboard_path, alert: t("flash.devise.already_authenticated.alert")
  end

  def redirect_unreleased_password_reset
    redirect_to new_user_session_path,
      alert: t("flash.devise.password_reset_unavailable.alert")
  end
end
