class Supports::Invoice::ShipperInvoices < Supports::Invoice
  def shipper_invoices
    @shipper_invoices ||= list_shipper_invoices
  end

  private
  def list_shipper_invoices
    @invoices.includes(shop: [:shop_setting]).collect do |invoice|
      support_shipper = Supports::Shipper::Shipper.new shipper: @current_user, invoice: invoice
      support_shop = Supports::User.new user: invoice.shop
      support_invoice = Supports::Invoice.new invoice: invoice


      shipper_invoice = support_invoice.base_invoice
      shipper_invoice[:user_invoice_id] = support_shipper.user_invoice_id
      shipper_invoice[:user] = support_shop.base_user
      unless invoice.init?
        support_status_histories = Supports::StatusInvoiceHistories.new status_invoice_historie: invoice.
          status_invoice_histories
        shipper_invoice[:status_histories] = support_status_histories.histories
      end
      shipper_invoice
    end
  end
end
