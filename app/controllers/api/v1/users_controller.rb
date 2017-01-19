class Api::V1::UsersController < Api::BaseController
  before_action :ensure_params_exist, except: :show
  before_action :find_object, only: [:show, :update]
  before_action :correct_user, only: :update
  before_action :ensure_params_true, only: :index

  def show
    users_simple = Simples::UsersSimple.new object: @user
    @user = users_simple.simple
    render json: {message: I18n.t("users.show.success"),
      data: {user: @user}, code: 1}, status: 200
  end

  def index
    if params[:user][:search]
      q = Hash.new
      q[:role] = if current_user.shop?
        "Shipper"
      elsif current_user.shipper?
        "Shop"
      end
      q[:data] = params[:user][:search]
      @users = current_user.search_user q
    else
      shipper_settings = ShipperSetting.near([current_user.user_setting.latitude,
        current_user.user_setting.longitude], Settings.max_distance, order: false).
        includes :shipper
      @users = User.users_by_user_setting(shipper_settings).users_online
    end
    users_simple = Simples::Shipper::ListShippersSimple.new object: @users.includes(:user_setting, :user_tokens)
    @users = users_simple.simple
    render json: {message: I18n.t("users.messages.get_shipper_success"),
      data: {users: @users}, code: 1}, status: 200
  end

  def update
    if @user.update_with_password user_params
      users_simple = Simples::UsersSimple.new object: @user
      @user = users_simple.simple
      render json: {message: I18n.t("users.messages.update_success"),
        data: {user: @user}, code: 1}, status: 200
    else
      render json: {message: error_messages(@user.errors.messages),
        data: {}, code: 0}, status: 200
    end
  end

  private
  def user_params
    params.require(:user).permit User::UPDATE_ATTRIBUTES_PARAMS
  end

  def ensure_params_true
    if params[:user].nil? || params[:user].class.to_s != "ActionController::Parameters"
      return render json: {message: I18n.t("api.missing_params"), data: {}, code: 0},
        status: 422
    else
      unless (params[:user][:distance] && params[:user][:latitude] && params[:user][:longitude]) ||
        params[:user][:search]
        render json: {message: I18n.t("api.missing_params"), data: {}, code: 0},
          status: 422
      end
    end
  end
end
