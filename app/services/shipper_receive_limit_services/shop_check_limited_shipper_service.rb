class ShipperReceiveLimitServices::ShopCheckLimitedShipperService
  attr_reader :args

  def initialize args
    @user_invoices = args[:user_invoices]
    @user_id = args[:user_id]
  end

  def perform
    @user_invoices.each do |user_invoice|
      user_invoice.rejected!
      HistoryServices::CreateUserInvoiceHistoryService.new(user_invoice: user_invoice,
        creater_id: @user_id, status: "rejected").perform
    end
  end
end
