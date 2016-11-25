class HistoryServices::CreateAllHistoryService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @creater_id = args[:creater_id]
    @status = args[:status]
  end

  def perform
    HistoryServices::CreateInvoiceHistoryService.new(invoice: @invoice,
      creater_id: @creater_id).perform
    HistoryServices::CreateUserInvoiceHistoryService.new(user_invoice: @user_invoice,
      status: @status, creater_id: @creater_id).perform
  end
end
