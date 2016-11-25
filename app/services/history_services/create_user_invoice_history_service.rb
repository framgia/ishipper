class HistoryServices::CreateUserInvoiceHistoryService
  attr_reader :args

  def initialize args
    @user_invoice = args[:user_invoice]
    @status = args[:status]
    @creater_id = args[:owner_id]
  end

  def perform
    @user_invoice.user_invoice_histories.create! status: @status, creater_id: @creater_id
  end
end
