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
        @user.user_setting.update_attributes signed_in: true
        users_simple = Simples::User::LoginUsersSimple.
          new object: @user, scope: {user_token: @user_token}
        @user = users_simple.simple
        render json: {message: t("api.sign_in.success"),
          data: {user: @user}, code: 1}, status: 200
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
      if !@user.online?
        @user.user_setting.update_columns signed_in: false
        if @user.shipper?
          shop_settings = UserSetting.near [@user.shipper_setting.latitude,
            @user.shipper_setting.longitude], Settings.max_distance, order: false
          @near_shops = Shop.users_by_user_setting(shop_settings).users_online
          shipper_is_offline
        end
      end
      render json: {message: t("api.sign_out.success"), data: {}, code: 1}, status: 200
    else
      render json: {message: t("api.invalid_token"), data: {}, code: 0}, status: 200
    end
  end

  private
  def user_params
    params.require(:user).permit :phone_number, :password, :registration_id
  end

  def invalid_login_attempt
    render json: {message: t("api.sign_in.fails"), data: {}, code: 0}, status: 200
  end

  def generate_user_token
    user_token = @user.user_tokens.find_by registration_id: user_params[:registration_id]
    user_token.destroy unless user_token.nil?
    @user_token = @user.user_tokens.create! authentication_token: Devise.friendly_token,
      registration_id: user_params[:registration_id]
  end

  def shipper_is_offline
    users_simple = Simples::UsersSimple.new object: @user
    @shipper = users_simple.simple
    realtime_visibility_shipper = ShipperServices::RealtimeVisibilityShipperService.
      new recipients: @near_shops, shipper: @shipper,
      action: Settings.realtime.shipper_offline
    realtime_visibility_shipper.perform
  end

  def load_user_authentication
    @user = User.includes(:invoices).find_for_database_authentication phone_number: user_params[:phone_number]
    return phone_number_invalid unless @user
  end
end
