class Api::V1::Shop::UserInvoicesController < Api::ShopBaseController
  before_action :find_object, :check_limited_shipper, :check_conditions_to_accept_shipper?,
    :check_black_list

  def update
    shop_accept_shipper = InvoiceServices::ShopAcceptShipperService.new invoice: @invoice,
      user_invoice: @user_invoice, status: "waiting", current_user: current_user
    if shop_accept_shipper.perform?
      render json: {message: I18n.t("invoices.accept_shipper.success"),
        data: {user_invoice: @user_invoice}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.accept_shipper.fail"), data: {},
        code: 0}, status: 200
    end
  end

  private
  def user_invoice_params
    params.require(:user_invoice).permit :invoice_id
  end

  def check_limited_shipper
    @user_invoices = @user_invoice.user.user_invoices
    user_invoices_init = @user_invoices.init
    unless @user_invoices.waiting.count < Settings.max_invoice
      shop_check_limited_shipper = ShipperReceiveLimitServices::ShopCheckLimitedShipperService.
        new user_invoices: user_invoices_init, user_id: 0
      shop_check_limited_shipper.perform
      render json: {message: I18n.t("user_invoices.receive_invoice.limit"),
        data: {user_invoice: @user_invoice}, code: 1}, status: 200
    end
  end

  def check_conditions_to_accept_shipper?
    @invoice = @user_invoice.invoice
    if !@invoice.init? || !@user_invoice.init?
      render json: {message: I18n.t("invoices.accept_shipper.fail"), data: {},
        code: 0}, status: 200
    end
  end
end
