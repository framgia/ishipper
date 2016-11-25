class ConditionRateServices::ShopConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @review_type = args[:review_type]
    @current_user = args[:current_user]
  end

  def perform?
    check_review_type? || check_shop_invoice_status?
  end
  private
  def check_review_type?
    @review_type != "rate"
  end

  def check_shop_invoice_status?
    @invoice.init? || @invoice.waiting? || @invoice.shipping? ||
      @invoice.cancel? || @invoice.shipped?
  end
end
