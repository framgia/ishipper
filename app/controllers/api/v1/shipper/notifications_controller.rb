class Api::V1::Shipper::NotificationsController < Api::ShipperBaseController
  before_action :check_param_exist, :find_notification, only: :update

  def index
    if params[:notification] && params[:notification][:page] &&
      params[:notification][:per_page]
      @notifications = current_user.passive_notifications.order_by_time.
        page(params[:notification][:page]).per params[:notification][:per_page]
      notifification_simple =  Simples::NotificationsSimple.
        new object: @notifications.includes(:owner, :invoice)
      @notifications = notifification_simple.simple
      update_notification = NotificationServices::UpdateNotificationService.new current_user: current_user,
        notification: nil, unread_notification: 0
      update_notification.perform
      render json: {message: I18n.t("notifications.messages.get_noti_success"),
        data: {notifications: @notifications, unread: 0}, code: 1}, status: 200
    else
      @unread_notification = current_user.shipper_setting.unread_notification
      render json: {message: I18n.t("notifications.messages.get_noti_success"),
        data: {notifications: [], unread: @unread_notification}, code: 1}, status: 200
    end
  end

  def update
    unread_notification = current_user.shipper_setting.unread_notification
    unread_notification = unread_notification - 1 if unread_notification > 0
    update_notification = NotificationServices::UpdateNotificationService.
      new current_user: current_user, notification: @notification,
      unread_notification: unread_notification
    if update_notification.perform
      render json: {message: I18n.t("notifications.update.success"),
        data:{}, code: 1}, status: 200
    else
      render json: {message: I18n.t("notifications.update.failed"), data: {},
        code: 0}, status: 200
    end
  end

  private
  def notification_params
    params.require(:notification).permit :read
  end

  def find_notification
    @notification = current_user.passive_notifications.find_by id: params[:id]
    if @notification.nil?
      render json: {message: I18n.t("notifications.messages.noti_not_exist"),
        data: {}, code: 0}, status: 200
    end
  end

  def check_param_exist
    if params[:notification].nil? || params[:notification][:read].nil?
      render json: {message: I18n.t("notifications.missing_params"), data: {},
        code: 0}, status: 422
    end
  end
end
