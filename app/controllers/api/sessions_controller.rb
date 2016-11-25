class Api::SessionsController < Devise::SessionsController
  include Confirm

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_signed_out_user

  before_action :ensure_params_exist, only: [:create, :destroy]
  before_action :load_user_authentication

  respond_to :json

  def create
    if @user.valid_password? user_params[:password]
      if @user.actived?
        sign_in @user, store: false
        generate_user_token
        @user.update_attributes signed_in: true
        serializer = ActiveModelSerializers::SerializableResource.new(@user,
          scope: {authentication: true, user_token: @user_token, current_user: current_user}).as_json
        render json: {message: t("api.sign_in.success"),
          data: {user: serializer}, code: 1}, status: 200
        return
      else
        render json: {message: t("api.sign_in.not_actived"), data: {}, code: 0},
          status: 200
        return
      end
    end
    invalid_login_attempt
  end

  def destroy
    token = @user.user_tokens.find_by authentication_token: params[:user][:authentication_token]
    if token
      sign_out @user
      token.destroy
      @user.update_attribute "signed_in", false
      render json: {message: t("api.sign_out.success"), data: {}, code: 1}, status: 200
    else
      render json: {message: t("api.invalid_token"), data: {}, code: 0}, status: 200
    end
  end

  private
  def user_params
    params.require(:user).permit :phone_number, :password
  end

  def invalid_login_attempt
    render json: {message: t("api.sign_in.fails"), data: {}, code: 0}, status: 200
  end

  def generate_user_token
    @user_token = @user.user_tokens.create! authentication_token: Devise.friendly_token,
      registration_id: user_params[:registration_id],
      device_id: user_params[:device_id]
  end
end
