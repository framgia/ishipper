class Supports::Invoice
  def initialize args
    args.each do |key, value|
      instance_variable_set "@#{key}", value
    end
  end

  def number_of_recipients
    @invoice.number_of_recipients
  end

  def status_histories
    @invoice.status_invoice_histories
  end

  def shipper
    unless @invoice.init?
      @user_invoice = @invoice.user_invoices.find{|user_invoice|
        user_invoice.status == @invoice.status}
      if @user_invoice
        users_simple = Simples::UsersSimple.new object: @user_invoice.user
        users_simple.simple
      end
    end
  end
end
