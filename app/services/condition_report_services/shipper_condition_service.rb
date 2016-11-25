class ConditionReportServices::ShipperConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @review_type = args[:review_type]
    @current_user = args[:current_user]
  end

  def perform?
    check_report_type? ||
    shipper_check_invoice_status? ||
    check_correct_shipper?
  end

  private
  def check_report_type?
    @review_type != "report"
  end

  def shipper_check_invoice_status?
    @invoice.init? || @invoice.shipping? || @invoice.shipped? || @invoice.finished?
  end

  def check_correct_shipper?
    @user_invoice.nil? || @current_user != @user_invoice.user
  end
end
