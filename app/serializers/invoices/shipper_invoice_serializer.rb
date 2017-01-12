class Invoices::ShipperInvoiceSerializer < InvoiceSerializer
  attribute :customer_number, if: :condition?
  attribute :customer_name, if: :condition?
  attributes :user_invoice_id, :user
  attribute :status_histories, if: :condition?

  def user
    serializer = ActiveModelSerializers::SerializableResource.new(object.user).as_json
  end

  def user_invoice_id
    user_invoice = UserInvoice.find_by invoice_id: object.id, user: scope[:current_user]
    if user_invoice
      user_invoice.id
    else
      0
    end
  end

  def status_histories
    ActiveModelSerializers::SerializableResource.new(object.status_invoice_histories,
      each_serializer: StatusInvoiceHistorySerializer)
  end
end
