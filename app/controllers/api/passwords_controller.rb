class Api::PasswordsController < Devise::PasswordsController
  prepend_before_action :require_no_authentication, only: [:new, :create]
  before_action :ensure_params_exist
  before_action :load_user, only: [:new, :create]
  before_action :load_user_authentication, only: :update

  def new
    @user.send_pin
    render json:
      {message: t("api.send_pin_success"), data: {}, code: 1},
      status: 200
  end

  def create
    if @user.pin == user_params[:pin]
      render json:
        {message: t("api.pin_valid"), data: {@user}, code: 1},
        status: 200
    else
      render json:
        {message: t("api.pin_invalid"), data: {}, code: 0},
        status: 204
    end
  end

  def update
    if @user.update_attributes user_params
      render json:
        {message: t("api.update.success"), data: {@user}, code: 1},
        status: 200
    else
      render json:
        {message: t("api.update.fail"), data: {@user.errors}, code: 0},
        status: 401
    end
  end

  private
  def user_params
    params.require(:user).permit :phone_number, :password,
      :password_confirmation, :pin
  end

  def load_user_authentication
    @user = User.find_for_database_authentication phone_number: user_params[:phone_number]
    return phone_number_invalid unless @user
  end

  def load_user
    @user = User.find_by_phone_number params[:user][:phone_number]
    return phone_number_invalid unless @user
  end

  def phone_number_invalid
    render json:
      {message: t("api.phone_number_invalid"), data: {}, code: 0},
      status: 401
  end

  def ensure_params_exist
    return unless params[:user].blank?
    render json:
      {message: t("api.missing_params"), data: {}, code: 0},
      status: 422
  end
end
