class Simples::Invoice::ShopInvoicesSimple < Simples::InvoicesSimple
  attr_accessor :status_histories, :number_of_recipients
  attr_accessor :user, if: :condition?

  def user
    user_invoice = @object.user_invoices.find{|user_invoice| user_invoice.status == @object.status}
    if user_invoice
      users_simple = Simples::UsersSimple.new object: user_invoice.user
      users_simple.simple
    end
  end

  def status_histories
    status_history = Simples::Invoice::StatusInvoiceHistoriesSimple.
      new object: @object.status_invoice_histories
    status_history.simple
  end

  def number_of_recipients
    if @object.init?
      @object.number_of_recipients
    end
  end
end
