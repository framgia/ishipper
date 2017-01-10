class Api::V1::InvoicesController < Api::BaseController
  before_action :ensure_params_exist, only: :index

  def index
    params[:black_list_user_id] = current_user.id
    invoices = Invoice.search params
    if invoices.any?
      invoices = Supports::Invoice::ShipperInvoices.new(invoices: invoices,
        current_user: current_user).shipper_invoices
      render json: {message: I18n.t("invoices.messages.get_invoices_success"),
        data: {invoices: invoices}, code: 1}, status: 200
    else
      render json: {message: I18n.t("invoices.messages.get_invoices_fails"),
        data: {}, code: 1}, status: 200
    end
  end

  private
  def ensure_params_exist
    if params[:user].nil? && params[:invoice].nil?
      render json: {message: I18n.t("api.missing_params"), data: {}, code: 0},
        status: 422
    end
  end
end
