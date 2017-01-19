class Api::V1::Shipper::BlackListsController < Api::ShipperBaseController
  before_action :ensure_params_exist, :check_black_user,
    :check_exist_black_list, :check_exist_favorite_list, :find_shop, only: :create
  before_action :load_and_check_black_list, only: :destroy

  def index
    @users = current_user.black_list_users
    users_simple = Simples::BaseSimple.new object: @users.includes(:user_setting), class_name:
      "Simples::User::BlackUsersSimple", scope: {current_user: current_user}
    @users = users_simple.simple
    render json: {message: I18n.t("black_list.get_black_list_success"),
      data: {users: @users}, code: 1}, status: 200
  end

  def create
    @black_list = BlackList.new black_list_params
    @black_list.owner = current_user
    if @black_list.save
      black_user = Simples::User::BlackUsersSimple.new object: @shop,
        scope: {current_user: current_user}
      @shop = black_user.simple
      render json: {message: I18n.t("black_list.create_success"),
        data: {user: @shop}, code: 1}, status: 200
    else
      render json: {message: I18n.t("black_list.create_fail"), data: {},
        code: 0}, status: 200
    end
  end

  def destroy
    @black_list.destroy
    render json: {message: I18n.t("black_list.destroy_success"), data: {},
      code: 1}, status: 200
  end

  private
  def black_list_params
    params.require(:black_list).permit BlackList::BLACK_LIST_ATTRIBUTES_PARAMS
  end

  def ensure_params_exist
    check_params = CheckParams.new attributes_params: BlackList::BLACK_LIST_ATTRIBUTES_PARAMS,
      params: params[:black_list]
    unless check_params.perform?
      render json: {message: I18n.t("black_list.missing_params"), data: {},
        code: 0}, status: 422
    end
  end

  def find_shop
    @shop = Shop.find_by_id params[:black_list][:black_list_user_id]
    unless @shop
      render json: {message: I18n.t("black_list.create_fail"), data: {},
        code: 0}, status: 200
    end
  end

  def check_black_user
    @user = User.find_by_id black_list_params[:black_list_user_id]
    render json: {message: I18n.t("black_list.black_user_invalid"), data: {},
      code: 0}, status: 200 if @user.nil? || !@user.shop?
  end

  def check_exist_black_list
    @black_list_user = current_user.black_list_users.
      find_by id: black_list_params[:black_list_user_id]
    if @black_list_user
      render json: {message: I18n.t("black_list.black_list_shop_exist"), data: {},
        code: 0}, status: 200
    end
  end

  def check_exist_favorite_list
    @favorite_list_user = current_user.favorite_list_users.
      find_by id: black_list_params[:black_list_user_id]
    if @favorite_list_user
      render json: {message: I18n.t("black_list.shop_in_favorite_list"),
        data: {}, code: 0}, status: 200
    end
  end

  def load_and_check_black_list
    @black_list = BlackList.find_by_id params[:id]
    unless @black_list && @black_list.owner == current_user
      render json: {message: I18n.t("black_list.destroy_fail"), data: {},
        code: 1}, status: 200
    end
  end
end
