class ConditionUpdateStatusServices::ShipperConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @update_status = args[:update_status]
    @current_user = args[:current_user]
  end

  def perform?
  # chi can 1 trong cac dieu kien sau TRUE, tuc la khong vuot qua duoc dieu kien de update
  @user_invoice.nil? || @invoice.shipped? || @invoice.finished? || @invoice.cancel? ||
    check_update_status_shipper? ||
    check_current_status? ||
    @user_invoice.status != @invoice.status
  end

  private
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

  def check_update_status_shipper?
    @update_status != "shipping" && @update_status != "shipped" &&
    @update_status != "cancel" && @update_status != "rejected"
  end
end
