class Api::V1::Shop::ListShippersController < Api::ShopBaseController
  before_action :ensure_params_true, :load_invoice, only: :index

  def index
    shippers = @invoice.all_shipper
    shippers = shippers - current_user.black_list_users
    shippers = ActiveModelSerializers::SerializableResource.new(shippers,
      each_serializer: Users::ListShipperSerializer, scope: {invoice: @invoice,
      current_user: current_user}).as_json
    if shippers.blank?
      render json: {message: I18n.t("invoices.messages.get_shippers_fails"),
      data: {}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.messages.get_shippers_success"),
      data: {shippers: shippers}, code: 1}, status: 200
    end
  end

  private
  def ensure_params_true
    if params[:invoice].nil? ||
      params[:invoice].class.to_s != "ActionController::Parameters" ||
      params[:invoice][:id].nil?
      return render json:
        {message: I18n.t("invoices.messages.missing_params"), data: {}, code: 0},
        status: 422
    end
  end

  def load_invoice
    @invoice = current_user.invoices.find_by id: params[:invoice][:id]
    if @invoice.nil?
      render json:
        {message: I18n.t("invoices.messages.invoice_not_exist"), data: {}, code: 0},
        status: 422
    end
  end
end
