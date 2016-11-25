class ConditionRateServices::ShipperConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @review_type = args[:review_type]
    @current_user = args[:current_user]
  end

  def perform?
    check_review_type? || check_ship_invoice_status? || check_correct_shipper?
  end

  private
  def check_review_type?
    @review_type != "rate"
  end

  def check_ship_invoice_status?
    @invoice.init? || @invoice.waiting? || @invoice.shipping? || @invoice.cancel?
  end

  def check_correct_shipper?
    @user_invoice.user != @current_user
  end
end
