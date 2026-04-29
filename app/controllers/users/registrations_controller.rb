class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_authenticated, only: %i[new]
  before_action :redirect_unreleased_account_settings, only: %i[edit update destroy]

  private

  def redirect_if_authenticated
    return unless user_signed_in?

    redirect_to dashboard_path, alert: t("flash.devise.already_authenticated.alert")
  end

  def redirect_unreleased_account_settings
    redirect_to dashboard_path, alert: t("flash.devise.account_settings_unavailable.alert")
  end
end
