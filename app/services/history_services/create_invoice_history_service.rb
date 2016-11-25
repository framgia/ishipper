class HistoryServices::CreateInvoiceHistoryService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @creater_id = args[:creater_id]
  end

  def perform
    invoice_params = @invoice.attributes.without *Invoice::REJECT_ATTRIBUTES
    invoice_params.merge "creater_id" => @creater_id
    @invoice.invoice_histories.create! invoice_params
  end
end
