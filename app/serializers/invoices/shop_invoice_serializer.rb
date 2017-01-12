class Invoices::ShopInvoiceSerializer < InvoiceSerializer
  attributes :customer_number, :customer_name
  attribute :user, if: :condition?
  attribute :number_of_recipients, unless: :condition?
  attribute :status_histories, if: :condition?

  def user
    user_invoice = UserInvoice.find_by invoice_id: object.id, status: object.status
    if user_invoice
      serializer = ActiveModelSerializers::SerializableResource.new(user_invoice.user).as_json
    end
  end

  def number_of_recipients
    object.received_shippers.size
  end

  def status_histories
    ActiveModelSerializers::SerializableResource.new(object.status_invoice_histories,
      each_serializer: StatusInvoiceHistorySerializer)
  end
end
