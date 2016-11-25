class ShipperReceiveLimitServices::NewShipperLimitService
  attr_reader :args

  def initialize args
    @user_id = args[:user_id]
  end

  def perform?
    current_invoices = User.find_by(id: @user_id).user_invoices
    @shipper_invoices = current_invoices.waiting.count +
      current_invoices.shipping.count + current_invoices.shipped.count +
      current_invoices.finished.count
    @shipper_invoices < Settings.new_shipper_invoice
  end
end
