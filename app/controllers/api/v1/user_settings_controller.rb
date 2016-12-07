class Api::V1::UserSettingsController < Api::BaseController
  include Authenticable
  include Confirm

  before_action :find_user_setting
  before_action :ensure_params_exist, only: :update

  def show
    render json: {message: I18n.t("user_setting.get.success"),
      data: {user_setting: @user_setting}, code: 1}, status: 200
  end

  def update
    if @user_setting.update_attributes user_setting_params
      render json: {message: I18n.t("user_setting.update.success"), data: {}, code: 1},
        status: 200
    else
      render json: {message: I18n.t("user_setting.update.fail"), data: {}, code: 1},
        status: 200
    end
  end

  private
  def user_setting_params
    params.require(:user_setting).permit UserSetting::ATTRIBUTES_PARAMS
  end

  def find_user_setting
    @user_setting = current_user.user_setting
  end
end
