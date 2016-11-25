class ShipperReceiveLimitServices::OldShipperLimitService
  attr_reader :args

  def initialize args
    @user_id = args[:user_id]
  end

  def perform?
    current_invoices = User.find_by(id: @user_id).user_invoices
    old_shipper = current_invoices.waiting.count + current_invoices.shipping.count
    old_shipper < Settings.max_invoice &&
      current_invoices.shipped.count < Settings.check_shipped_invoice
  end
end
