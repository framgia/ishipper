class ConditionReportServices::ShopConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @review_type = args[:review_type]
    @current_user = args[:current_user]
  end

  def perform?
    check_report_type? || shop_check_invoice_status?
  end

  private
  def check_report_type?
    @review_type != "report"
  end

  def shop_check_invoice_status?
    @invoice.init? || @invoice.shipped? || @invoice.finished?
  end
end
