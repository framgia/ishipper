class Api::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_params_exist

  respond_to :json

  def create
    user = User.new user_params
    if user.save
      if user.unactive?
        user.send_pin
      end
      render json:
        {message: t("api.sign_up.success"), data: {user: user}, code: 1},
        status: 201
    else
      warden.custom_failure!
      render json:
        {message: user.errors.messages, data: {}, code: 0},
        status: 422
    end
  end

  private
  def user_params
    params.require(:user).permit :phone_number, :password,
      :password_confirmation, :status, :role
  end

  def ensure_params_exist
    return unless params[:user].blank?
    render json:
      {message: t("api.missing_params"), data: {}, code: 0},
      status: 422
  end
end
