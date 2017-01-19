class Api::V1::Shipper::InvoicesController < Api::ShipperBaseController
  before_action :find_object, :check_black_list, only: [:update, :show]
  before_action :ensure_params_true, only: [:index, :update]
  before_action :check_conditions_to_update_status?, only: :update

  def index
    @invoices = if params[:status] == "all"
      current_user.invoices
    else
      Invoice.invoice_by_status_for_shipper params[:status], current_user.id
    end
    @q = Hash.new
    @q[:type] = "name"
    @q[:data] = params[:query]
    @invoices = @invoices.order_by_update_time
    @invoices = @invoices.search_invoice @q if params[:query].present?
    if @invoices.any?
      invoices_simple = Simples::Invoice::ShipperInvoicesSimple.
        new object: @invoices.includes(:status_invoice_histories, :user_invoices,
        user: [:user_setting]), scope: {current_user: current_user}
      @invoices = invoices_simple.simple
    end
    render json: {message: I18n.t("invoices.messages.get_invoices_success"),
      data: {invoices: @invoices}, code: 1}, status: 200
  end

   def show
    if @invoice.present?
      invoice_simple = Simples::Invoice::ShipperInvoicesSimple.new object: @invoice,
        scope: {current_user: current_user}
      @invoice = invoice_simple.simple
      render json: {message: I18n.t("invoices.show.success"),
        data: {invoice: @invoice}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.messages.not_found"),
        data: {}, code: 0}, status: 200
    end
  end

  def update
    shipper_update_status = InvoiceServices::ShipperUpdateStatusService.new invoice: @invoice,
      user_invoice: @user_invoice, update_status: params[:status], current_user: current_user
    if shipper_update_status.perform?
      render json: {message: I18n.t("invoices.messages.update_success"),
        data: {invoice: @invoice}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.messages.update_fail"),
        data: {}, code: 0}, status: 200
    end
  end

  private
  def ensure_params_true
    statuses = UserInvoice.statuses
    statuses["all"] = 7
    if params[:status].nil? || !params[:status].in?(statuses)
      render json: {message: I18n.t("invoices.messages.missing_params"),
        data: {}, code: 0}, status: 422
    end
  end

  def check_conditions_to_update_status?
    @user_invoice = @invoice.user_invoices.find_by user_id: current_user.id,
      status: @invoice.status
    shipper_condition = ConditionUpdateStatusServices::ShipperConditionService.new invoice: @invoice,
      user_invoice: @user_invoice, update_status: params[:status], current_user: current_user
    if !shipper_condition.perform?
      render json: {message: I18n.t("invoices.messages.cant_update"),
        data: {}, code: 0}, status: 200
    end
  end
end
