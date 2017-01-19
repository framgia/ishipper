class Simples::InvoicesSimple < Simples::BaseSimple
  attr_accessor :id, :name, :address_start, :latitude_start, :longitude_start,
    :address_finish, :latitude_finish, :longitude_finish, :delivery_time,
    :distance_invoice, :description, :price, :shipping_price, :status, :weight,
    :user_id, :customer_number, :customer_name

  def condition?
    if @object.init?
      false
    else
      true
    end
  end
end
