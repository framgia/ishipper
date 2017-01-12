class Supports::Shop::Shops < Supports::User
  def initialize args
    @shop = args[:shop]
  end

  def shop
    Hash[:id, @shop.id,
      :name, @shop.name,
      :email, @shop.email,
      :address, @shop.address,
      :current_location, @shop.shop_setting.current_location,
      :latitude, @shop.shop_setting.latitude,
      :longitude, @shop.shop_setting.longitude,
      :phone_number, @shop.phone_number,
      :role, @shop.role,
      :rate, @shop.rate
    ]
  end
end
