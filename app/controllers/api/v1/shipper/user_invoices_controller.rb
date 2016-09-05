class Api::V1::Shipper::UserInvoicesController < Api::ShipperBaseController
  before_action :ensure_params_exist, :check_received_invoice, only: :create
  before_action :check_delete_user_invoice, only: :destroy

  def create
    @user_invoice = current_user.user_invoices.build user_invoice_params
    if ShipperReceiveLimit.new(@user_invoice, current_user).check_new_shipper?
      if @user_invoice.save
        InvoiceHistoryCreator.new(@invoice, current_user).
          create_user_invoice_history @user_invoice, "init"
        render json: {message: I18n.t("user_invoices.receive_invoice.success"),
          data: {user_invoice: @user_invoice}, code: 1}, status: 200
      else
        render json: {message: I18n.t("user_invoices.receive_invoice.fail"), data: {},
          code: 0}, status: 200
      end
    else
      if ShipperReceiveLimit.new(@user_invoice, current_user).check_old_shipper?
        if @user_invoice.save
          InvoiceHistoryCreator.new(@invoice, current_user).
            create_user_invoice_history @user_invoice, "init"
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
    user_invoice = current_user.user_invoices.find_by invoice: @invoice
    if user_invoice
      render json: {message: I18n.t("user_invoices.receive_invoice.received"),
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
end
