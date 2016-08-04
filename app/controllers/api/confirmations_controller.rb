class Api::ConfirmationsController < Devise::ConfirmationsController
  before_action :ensure_params_exist
  before_action :load_user_authentication, only: :update

  respond_to :json

  def new
    @user.send_pin
    render json:
      {message: t("api.send_pin_success"), data: {}, code: 1},
      status: 200
  end

  def update
    if @user.pin == user_params[:pin]
      if @user.update_attributes user_params
        if @user.unactive?
          @user.actived!
        end
        render json:
          {message: t("api.update.success"), data: {user: @user}, code: 1},
          status: 200
      else
        render json:
          {message: t("api.update.fail"), data: {user: @user.errors}, code: 0},
          status: 422
      end
    else
      render json:
        {message: t("api.pin_invalid"), data: {}, code: 0},
        status: 204
    end
  end

  private
  def user_params
    params.require(:user).permit :phone_number, :pin
  end

  def load_user_authentication
    @user = User.find_for_database_authentication phone_number: user_params[:phone_number]
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
