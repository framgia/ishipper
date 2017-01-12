class Supports::Invoice
  attr_reader :invoice

  def initialize args
    @invoice = args[:invoice]
    @current_user = args[:current_user]
    @invoices = args[:invoices]
  end

  def list_receive_shippers
    @shippers = @invoice.received_shippers
    ActiveModelSerializers::SerializableResource.new(@shippers,
      each_serializer: Users::ListShipperSerializer, scope: {invoice: @invoice,
      current_user: @current_user})
  end

  def number_of_recipients
    @invoice.number_of_recipients
  end

  def status_histories
    @invoice.status_invoice_histories
  end

  def shipper
    unless @invoice.init?
      @user_invoice = @invoice.user_invoices.find_by status: @invoice.status
      if @user_invoice
        ActiveModelSerializers::SerializableResource.new(@user_invoice.user).as_json
      end
    end
  end

  def base_invoice
    Hash[:id, @invoice.id,
      :name, @invoice.name,
      :address_start, @invoice.address_start,
      :latitude_start, @invoice.latitude_start,
      :longitude_start, @invoice.longitude_start,
      :address_finish, @invoice.address_finish,
      :latitude_finish, @invoice.latitude_finish,
      :longitude_finish, @invoice.longitude_finish,
      :delivery_time, @invoice.delivery_time,
      :distance_invoice, @invoice.distance_invoice,
      :description, @invoice.description,
      :price, @invoice.price,
      :shipping_price, @invoice.shipping_price,
      :status, @invoice.status,
      :weight, @invoice.weight
    ]
  end
end
