class Api::V1::Shop::InvoicesController < Api::ShopBaseController
  before_action :ensure_params_true, only: :index
  before_action :ensure_params_exist, only: :create
  before_action :find_object, :check_black_list, only: [:update, :destroy, :show]
  before_action :check_conditions_to_update_status?, only: :update

  def index
    @invoices = if params[:status] == "all"
      current_user.invoices
    else
      current_user.invoices.send("#{params[:status]}")
    end
    @q = Hash.new
    @q[:type] = "name"
    @q[:data] = params[:query]
    @invoices = @invoices.search_invoice @q if params[:query].present?
    @invoices = @invoices.order_by_update_time
    @serializers = ActiveModelSerializers::SerializableResource.new(@invoices,
      each_serializer: Invoices::ShopInvoiceSerializer,
      scope: {current_user: current_user}).as_json
    render json: {message: I18n.t("invoices.messages.get_invoices_success"),
      data: {invoices: @serializers}, code: 1}, status: 200
  end

  def show
    @serializer = Invoices::ShopInvoiceSerializer.new(@invoice,
      scope: {current_user: current_user}).as_json
    render json: {message: I18n.t("invoices.show.success"),
      data: {invoice: @serializer}, code: 1}, status: 200
  end

  def create
    @invoice = current_user.invoices.build invoice_params
    if @invoice.save
      create_invoice_history = HistoryServices::CreateInvoiceHistoryService.new invoice: @invoice,
        creater_id: current_user.id
      create_invoice_history.perform
      create_status_invoice_history = HistoryServices::CreateStatusInvoiceHistoryService.new invoice: @invoice
      create_status_invoice_history.perform
      render json: {message: I18n.t("invoices.create.success"),
        data: {invoice: @invoice}, code: 1}, status: 200

      @passive_favorites = current_user.passive_favorites
      if @passive_favorites.any?
        send_all_notification = NotificationServices::SendAllNotificationService.new owner: current_user,
          recipients: @passive_favorites, status: "favorite", invoice: @invoice, click_action: Settings.invoice_detail
        send_all_notification.perform
      end

      @serializer = Invoices::ShipperInvoiceSerializer.new(@invoice,
        scope: {current_user: current_user}).as_json
      @shipper_setting = ShipperSetting.near [@invoice.latitude_start, @invoice.longitude_start],
        Settings.max_distance, order: false
      @near_shippers = Shipper.users_by_user_setting(@shipper_setting).users_online
      if @near_shippers.any?
        realtime_visibility_shipper = InvoiceServices::RealtimeVisibilityInvoiceService.new recipients: @near_shippers,
          invoice: @serializer, action: Settings.realtime.new_invoice
        realtime_visibility_shipper.perform
      end
    else
      render json: {message: error_messages(@invoice.errors.messages), data: {},
        code: 0}, status: 200
    end
  end

  def update
    if params[:status]
      shop_update_status = InvoiceServices::ShopUpdateStatusService.new invoice: @invoice,
        user_invoice: @user_invoice, update_status: params[:status], current_user: current_user
      if shop_update_status.perform?
        render json: {message: I18n.t("invoices.messages.update_success"),
          data: {invoice: @invoice}, code: 1}, status: 200
      else
        render json: {message: I18n.t("invoices.messages.invoice_error_status"),
          data: {}, code: 0}, status: 200
      end
    else
      if @invoice.init?
        if @invoice.update_attributes invoice_params
          create_invoice_history = HistoryServices::CreateInvoiceHistoryService.new invoice: @invoice,
            creater_id: current_user.id
          create_invoice_history.perform
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
    @user_invoice = @invoice.user_invoices.find_by status: @invoice.status
    shop_condition = ConditionUpdateStatusServices::ShopConditionService.new invoice: @invoice,
      user_invoice: @user_invoice, update_status: params[:status], current_user: current_user
    if !shop_condition.perform?
      render json: {message: I18n.t("invoices.messages.cant_update"),
        data: {}, code: 0}, status: 200
    end
  end

  def ensure_params_exist
    check_params = CheckParams.new attributes_params: Invoice::ATTRIBUTES_PARAMS,
      params: params[:invoice]
    unless check_params.perform?
      render json: {message: I18n.t("invoices.messages.missing_params"),
        data: {}, code: 0}, status: 422
    end
  end
end
