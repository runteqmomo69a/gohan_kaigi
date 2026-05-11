class Users::PasswordsController < Devise::PasswordsController
  before_action :redirect_if_authenticated, only: %i[new edit]

  private

  def redirect_if_authenticated
    return unless user_signed_in?

    redirect_to dashboard_path, alert: t("flash.devise.already_authenticated.alert")
  end
end
