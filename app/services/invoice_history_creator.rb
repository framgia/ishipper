class InvoiceHistoryCreator
  def initialize invoice
    @invoice = invoice
  end

  def create_history invoice_params
    @invoice.assign_attributes invoice_params
    create_invoice_history
    if @invoice.save
      return true 
    else
      return false
    end
  end

  def create_invoice_history
    @invoice.changes.each do |attribute_name, value|
      before_value = value[0]
      after_value = value[1]
      user_id = @invoice.user_id
      @invoice.invoice_histories.create! user_id: user_id,
        attribute_name: attribute_name, before_value: before_value,
        after_value: after_value
    end
  end

  def create_user_history user_invoice, status
    user_invoice.assign_attributes status: status
    user_invoice.changes.each do |attribute_name, value|
      before_value = value[0]
      after_value = value[1]
      user_invoice.user_invoice_histories.create!(
        attribute_name: attribute_name, before_value: before_value,
        after_value: after_value
        )
    end
  end

  def create_all_history user_invoice, status
    create_invoice_history
    create_user_history user_invoice, status
  end
end
