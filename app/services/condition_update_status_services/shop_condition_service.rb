class ConditionUpdateStatusServices::ShopConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @update_status = args[:update_status]
    @current_user = args[:current_user]
  end

  def perform?
    # chi can 1 trong cac dieu kien sau TRUE, tuc la khong vuot qua duoc dieu kien de update
    @invoice.user != @current_user ||
      check_update_status_shop? ||
      check_user_invoice_present? ||
      check_current_status?
  end

  private
  def check_user_invoice_present?
    @user_invoice.nil? && !@invoice.init?
  end

  def check_status?
    @update_status.class.to_s == "String"
  end

  def check_current_status?
    if check_status?
      statuses = Invoice.statuses
      true unless statuses.has_key?(@invoice.status) && statuses.has_key?(@update_status)
      if "cancel" == @update_status && "finished" != @invoice.status &&
        "cancel" != @invoice.status
        false
      elsif "rejected" == @update_status || "init" == @update_status
        true
      elsif statuses[@update_status].pred == statuses[@invoice.status] &&
        "finished" != @invoice.status
        false
      else
        true
      end
    else
      true
    end
  end

  def check_update_status_shop?
    @update_status != "finished" && @update_status != "cancel"
  end
end
