class InvoiceServices::ShopAcceptShipperService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @status = args[:status]
    @current_user = args[:current_user]
  end

  def perform?
    ActiveRecord::Base.transaction do
      @user_invoice.update_attributes status: @status
      @invoice.update_attributes status: @status
      HistoryServices::CreateAllHistoryService.new(invoice: @invoice,
        user_invoice: @user_invoice, creater_id: @current_user.id,
        status: @status).perform
      NotificationServices::CreateNotificationService.new(owner: @current_user,
        recipient: @user_invoice.user, status: @status, invoice: @invoice,
        click_action: Settings.invoice_detail, invoice_simple: @invoice).perform
      @invoice.user_invoices.each do |user_invoice|
        unless @user_invoice == user_invoice
          user_invoice.rejected!
          HistoryServices::CreateUserInvoiceHistoryService.new(user_invoice: user_invoice,
            creater_id: @current_user.id, status: "rejected").perform
        end
      end
      shippper_setting = ShipperSetting.near [@invoice.latitude_start, @invoice.longitude_start],
        Settings.max_distance, order: false
      near_shippers = Shipper.users_by_user_setting(shippper_setting).users_online
      if near_shippers.any?
        InvoiceServices::RealtimeVisibilityInvoiceService.new(recipients: near_shippers,
          invoice: @invoice, action: Settings.realtime.remove_invoice).perform
      end
    end
    return true
    rescue =>e
    return false
  end
end
