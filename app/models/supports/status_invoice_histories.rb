class Supports::StatusInvoiceHistories
  def initialize args
    @status_invoice_historie = args[:status_invoice_historie]
  end

  def histories
    @status_invoice_historie.collect do |status_invoice_history|
      status_invoice = Hash.new
      status_invoice[:id] = status_invoice_history.id
      status_invoice[:time] = status_invoice_history.time
      status_invoice[:content] = I18n.t "status_history.#{status_invoice_history.status}"
      status_invoice
    end
  end
end
