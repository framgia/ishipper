class Api::V1::Shop::InvoicesController < Api::ShopBaseController
  before_action :ensure_params_true, only: :index
  before_action :ensure_params_exist, only: :create
  before_action :find_object, :check_black_list, only: [:update, :destroy, :show]
  before_action :check_conditions_to_update_status?, only: :update

  def index
    invoices = if params[:status] == "all"
      current_user.invoices.search_invoice(params[:query]).order_by_time
    else
      current_user.invoices.send(params[:status]).
        search_invoice(params[:query]).order_by_time
    end
    render json: {message: I18n.t("invoices.messages.get_invoices_success"),
      data: {invoices: invoices}, code: 1}, status: 200
  end

  def show
    if @invoice.present?
      serializer = ActiveModelSerializers::SerializableResource.new(@invoice,
        each_serializer: InvoiceSerializer, scope: current_user).as_json
      render json: {message: I18n.t("invoices.show.success"),
        data: {invoice: serializer}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.messages.not_found"),
        data: {}, code: 0}, status: 200
    end
  end

  def create
    invoice = current_user.invoices.build invoice_params
    passive_favorites = current_user.passive_favorites
    near_shippers = User.near([invoice.latitude_start, invoice.longitude_start],
      Settings.max_distance).shipper.is_online
    if invoice.save
      HistoryServices::CreateInvoiceHistoryService.new(invoice: invoice,
        creater_id: current_user.id).perform
      click_action = Settings.invoice_detail
      render json: {message: I18n.t("invoices.create.success"),
        data: {invoice: invoice}, code: 1}, status: 201
      if passive_favorites.any?
        NotificationServices::SendAllNotificationService.new(owner: current_user,
          recipients: passive_favorites, content: "favorite", invoice: invoice,
          click_action: click_action).perform
      end
      serializer = ActiveModelSerializers::SerializableResource.new(invoice,
        each_serializer: InvoiceSerializer, scope: current_user).as_json
      if near_shippers.any?
        InvoiceServices::RealtimeVisibilityInvoiceService.new(recipients: near_shippers,
          invoice: serializer, action: Settings.realtime.new_invoice).perform
      end
    else
      render json: {message: error_messages(invoice.errors.messages), data: {},
        code: 0}, status: 200
    end
  end

  def update
    if params[:status]
      if InvoiceServices::ShopUpdateStatusService.new(invoice: @invoice,
        user_invoice: @user_invoice, status: params[:status],
        current_user: current_user).perform
        render json: {message: I18n.t("invoices.messages.update_success"),
          data: {invoice: @invoice}, code: 1}, status: 200
      else
        render json: {message: I18n.t("invoices.messages.invoice_error_status"),
          data: {}, code: 0}, status: 200
      end
    else
      if @invoice.init?
        if @invoice.update_attributes invoice_params
          HistoryServices::CreateInvoiceHistoryService.new(invoice: @invoice,
            creater_id: current_user.id).perform
          render json: {message: I18n.t("invoices.update.success"),
            data:{invoice: @invoice}, code: 1}, status: 200
        else
          render json: {message: error_messages(@invoice.errors.messages), data: {},
            code: 0}, status: 200
        end
      else
        render json: {message: I18n.t("invoices.messages.cant_update"),
          data: {}, code: 0}, status: 200
      end
    end
  end

  def destroy
    if current_user == @invoice.user && @invoice.destroy
      render json: {message: I18n.t("invoices.delete.success"), data: {},
        code:1}, status: 200
    else
      render json: {message: I18n.t("invoices.delete.fails"), data: {},
        code:0},status: 200
    end
  end

  private
  def ensure_params_true
    statuses = Invoice.statuses
    statuses["all"] = 7
    unless (params[:status].nil? || params[:status].in?(statuses)) &&
      params.has_key?(:status)
      render json: {message: I18n.t("invoices.messages.missing_params"),
        data: {}, code: 0}, status: 422
    end
  end

  def invoice_params
    params.require(:invoice).permit Invoice::ATTRIBUTES_PARAMS
  end

  def check_conditions_to_update_status?
    statuses = Invoice.statuses
    if params[:status] && params[:status].in?(statuses)
      @user_invoice = @invoice.user_invoices.find_by status: @invoice.status
      if ConditionUpdateStatusServices::ShopConditionService.new(invoice: @invoice,
        user_invoice: @user_invoice, update_status: params[:status],
        current_user: current_user).perform?
        render json: {message: I18n.t("invoices.messages.cant_update"),
          data: {}, code: 0}, status: 200
      end
    end
  end

  def ensure_params_exist
    unless CheckParams.new(attributes_params: Invoice::ATTRIBUTES_PARAMS,
      params: params[:invoice]).perform?
      render json: {message: I18n.t("invoices.messages.missing_params"),
        data: {}, code: 0}, status: 422
    end
  end
end
