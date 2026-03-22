class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    auth = request.env["omniauth.auth"]

    @user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    if @user.new_record?
      @user.email = dummy_email(auth)
      @user.name = auth.info.name.presence || "LINEユーザー"
      @user.password = Devise.friendly_token[0, 20]
      @user.save
    end

    if @user.persisted?
      sign_in @user
      redirect_to dashboard_path, notice: "LINEでログインしました"
    else
      redirect_to new_user_session_path, alert: "LINEログインに失敗しました"
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "LINEログインに失敗しました"
  end

  private

  def dummy_email(auth)
    "#{auth.uid}-line@example.com"
  end
end