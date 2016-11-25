class Api::V1::Shipper::UserInvoicesController < Api::ShipperBaseController
  before_action :ensure_params_exist, :check_received_invoice,
    :check_invoice_status, only: :create
  before_action :check_delete_user_invoice, only: :destroy
  before_action :check_black_list

  def create
    @user_invoice = current_user.user_invoices.build user_invoice_params
    if ShipperReceiveLimitServices::NewShipperLimitService.new(user_id: current_user.id).perform?
      if @user_invoice.save
        HistoryServices::CreateUserInvoiceHistoryService.new(user_invoice: @user_invoice,
          creater_id: current_user.id, status: "init").perform
        click_action = Settings.list_shipper_register
        NotificationServices::CreateNotificationService.new(owner: current_user,
          recipient: @invoice.user, content: "receive", invoice: @invoice,
          click_action: click_action).perform
        render json: {message: I18n.t("user_invoices.receive_invoice.success"),
          data: {user_invoice: @user_invoice}, code: 1}, status: 200
      else
        render json: {message: I18n.t("user_invoices.receive_invoice.fail"), data: {},
          code: 0}, status: 200
      end
    else
      if ShipperReceiveLimitServices::OldShipperLimitService.new(user_id: current_user.id).perform?
        if @user_invoice.save
          HistoryServices::CreateUserInvoiceHistoryService.new(user_invoice: @user_invoice,
            creater_id: current_user.id, status: "init").perform
          click_action = Settings.list_shipper_register
          NotificationServices::CreateNotificationService.new(owner: current_user,
            recipient: @invoice.user, content: "receive", invoice: @invoice,
            click_action: click_action).perform
          render json: {message: I18n.t("user_invoices.receive_invoice.success"),
            data: {user_invoice: @user_invoice}, code: 1}, status: 200
        else
          render json: {message: I18n.t("user_invoices.receive_invoice.fail"), data: {},
            code: 0}, status: 200
        end
      else
        render json: {message: I18n.t("user_invoices.receive_invoice.limit"), data: {},
          code: 0}, status: 200
      end
    end
  end

  def destroy
    if @user_invoice_delete.destroy
      render json: {message: I18n.t("user_invoices.delete.success"), data: {},
        code:1}, status: 200
    else
      render json: {message: I18n.t("user_invoices.delete.fails"), data: {},
        code:0},status: 200
    end
  end

  private
  def user_invoice_params
    params.require(:user_invoice).permit :invoice_id
  end

  def check_received_invoice
    @invoice = Invoice.find_by id: params[:user_invoice][:invoice_id]
    if @invoice.nil?
      render json: {message: I18n.t("invoices.messages.invoice_not_found"),
        data: {}, code: 0}, status: 200
    end
    user_invoice = current_user.user_invoices.find_by invoice: @invoice, status: "init"
    if user_invoice
      render json: {message: I18n.t("user_invoices.receive_invoice.received"),
        data: {}, code: 0}, status: 200
    end
  end

  def check_invoice_status
    unless @invoice.init?
      render json: {message: I18n.t("user_invoices.receive_invoice.fail"),
        data: {}, code: 0}, status: 200
    end
  end

  def check_delete_user_invoice
    user_invoices = Invoice.find_by(id: params[:id]).user_invoices
    @user_invoice_delete = user_invoices.find_by user: current_user
    if @user_invoice_delete.nil?
      render json: {message: I18n.t("user_invoices.delete.nil"), data: {},
        code:0},status: 200
    end
  end

  def check_black_list
    @invoice = Invoice.find_by_id user_invoice_params[:invoice_id]
    black_list = BlackList.find_by owner_id: @invoice.user_id,
      black_list_user_id: current_user.id
    if black_list
      render json: {message: I18n.t("black_list.permission_denied"), data: {},
        code: 1}, status: 200
    end
  end
end
