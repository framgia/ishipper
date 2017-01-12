module Authenticable
  def current_user
    @user_token ||= UserToken.includes(:user).find_by authentication_token: request.headers["Authorization"]
    if @user_token
      @current_user ||= @user_token.user
    end
  end

  def authenticate_with_token!
    if current_user.nil?
      render json: {message: I18n.t("api.not_authenticated"), data: {},
        code: 0}, status: 401
    elsif current_user.present? && current_user.unactive?
      render json: {message: I18n.t("api.sign_in.not_actived"), data: {},
        code: 0}, status: 401
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def correct_user
    render json: {message: I18n.t("messages.wrong_permission"),
      data: {}, code: 0}, status: 422 unless current_user.current_user? @user
  end
end
