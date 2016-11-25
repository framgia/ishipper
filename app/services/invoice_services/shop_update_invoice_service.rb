class InvoiceServices::ShopUpdateInvoiceService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @status = args[:status]
    @current_user = args[:current_user]
  end

  def perform?
    if check_conditions_to_update_status?
      if InvoiceServices::ShopUpdateStatusService.new(invoice: @invoice,
        user_invoice: @user_invoice, status: @status, current_user: @current_user).perform
        true
      elsif shop_update_attributes(@status)
        HistoryServices::CreateInvoiceHistoryService.new(invoice: @invoice,
          creater_id: @current_user.id).perform
        true
      else
        false
      end
    else
      false
    end
  end
  private
  def shop_update_attributes invoice_params
    (@status || !@invoice.init?) ? false : @invoice.update_attributes(invoice_params)
  end

  def check_conditions_to_update_status?
    if @status && Invoice.statuses.include?(@status)
      @user_invoice = @invoice.user_invoices.find_by status: @invoice.status
      !ConditionUpdateStatusServices::ShopConditionService.new(invoice: @invoice,
        user_invoice: @user_invoice, update_status: @status,
        current_user: @current_user).perform?
    end
  end
end
