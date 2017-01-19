class Simples::Invoice::DetailInvoicesSimple < Simples::InvoicesSimple
  attr_accessor :user, :status_histories, :user_invoice_id, :number_of_recipients

  def user
    users_simple = Simples::UsersSimple.new object: @object.user
    users_simple.simple
  end

  def user_invoice_id
    @user_invoice = @object.user_invoices.find{|user_invoice|
      user_invoice.user_id == @current_user.id && user_invoice.status == @object.status}
    @user_invoice ? @user_invoice.id : 0
  end

  def status_histories
    status_history = Simples::Invoice::StatusInvoiceHistoriesSimple.
      new object: @object.status_invoice_histories
    status_history.simple
  end

  def number_of_recipients
    if @object.init? && @current_user.shop?
      @object.number_of_recipients
    end
  end
end
