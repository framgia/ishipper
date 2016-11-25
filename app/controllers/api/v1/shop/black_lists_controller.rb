class Api::V1::Shop::BlackListsController < Api::ShopBaseController
  before_action :ensure_params_true, :check_user_exist, :check_exist_black_list,
    only: :create
  before_action :load_and_check_black_list, only: :destroy

  def index
    users = current_user.black_list_users
    users = ActiveModelSerializers::SerializableResource.new(users,
      each_serializer: UserSerializer, scope: {current_user: current_user})
    render json: {message: I18n.t("black_list.get_black_list_success"),
      data: {users: users}, code: 1}, status: 200
  end

  def create
    black_list = BlackList.new black_list_params
    black_list.owner = current_user
    if black_list.save
      render json: {message: I18n.t("black_list.create_success"),
        data: {black_list: black_list}, code: 1}, status: 200
    else
      render json: {message: I18n.t("black_list.create_fail"),
        data: {}, code: 0}, status: 200
    end
  end

  def destroy
    @black_list.destroy
    render json: {message: I18n.t("black_list.destroy_success"), data: {},
      code: 1}, status: 200
  end

  private
  def ensure_params_true
    unless CheckParams.new(attributes_params: BlackList::BLACK_LIST_ATTRIBUTES_PARAMS,
      params: params[:black_list]).perform?
      render json: {message: I18n.t("api.missing_params"), data: {},
        code: 0}, status: 422
    end
  end

  def black_list_params
    params.require(:black_list).permit BlackList::BLACK_LIST_ATTRIBUTES_PARAMS
  end

  def check_exist_black_list
    black_list_user = current_user.black_list_users.
      find_by id: black_list_params[:black_list_user_id]
    if black_list_user
      render json: {message: I18n.t("black_list.black_list_shop_exist"), data: {},
        code: 0}, status: 200
    end
  end

  def check_user_exist
    user = User.find_by id: black_list_params[:black_list_user_id]
    render json: {message: I18n.t("black_list.user"), data: {}, code: 0},
      status: 422 if user.nil? or user.shop?
  end

  def load_and_check_black_list
    @black_list = BlackList.find_by_id params[:id]
    unless @black_list && @black_list.owner == current_user
      render json: {message: I18n.t("black_list.destroy_fail"), data: {},
        code: 1}, status: 200
    end
  end
end
