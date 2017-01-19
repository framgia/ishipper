class Api::V1::Shop::ListShippersController < Api::ShopBaseController
  before_action :ensure_params_true, :load_invoice, only: :index

  def index
    @shippers = @invoice.received_shippers
    shippers_simple = Simples::Shipper::ListShippersSimple.new object: @shippers.
      includes(:user_invoices, :user_setting, :user_tokens), scope: {current_user: current_user, invoice: @invoice}
    @shippers = shippers_simple.simple
    if @shippers.blank?
      render json: {message: I18n.t("invoices.messages.get_shippers_fails"),
        data: {}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.messages.get_shippers_success"),
        data: {shippers: @shippers}, code: 1}, status: 200
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
