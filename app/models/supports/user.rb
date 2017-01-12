class Supports::User
  attr_reader :current_user

  def initialize args
    @current_user = args[:current_user]
    @params = args[:params]
    @user = args[:user]
  end

  def base_user
    Hash[:id, @user.id,
      :name, @user.name,
      :email, @user.email,
      :address, @user.address,
      :current_location, @user.user_setting.current_location,
      :latitude, @user.user_setting.latitude,
      :longitude, @user.user_setting.longitude,
      :phone_number, @user.phone_number,
      :plate_number, @user.plate_number,
      :role, @user.role,
      :rate, @user.rate
    ]
  end

  ["favorite_list_users", "black_list_users"].each do |user_type|
    define_method user_type do
      instance_variable_set("@#{user_type}", @current_user.send(user_type)) unless
        instance_variable_get "@#{user_type}"
    end
  end

  def reviews
    @current_user.passive_reviews
  end

  Settings.rate.list_rate.each do |rate|
    define_method rate do
      instance_variable_set "@#{rate}", reviews.where(rating_point:
        Settings.rate.send(rate), review_type: "rate").size unless
        instance_variable_get "@#{rate}"
    end
  end

  def sum_rate
    sum = 0
    Settings.rate.list_rate.each do |rate|
      sum += send(rate)
    end
    sum
  end

  def user_invoice_id
    @params[:user_invoice_id] if @params
  end

  def invoice
    Invoice.find_by id: @params[:invoice_id] if @params
  end

  def create_invoice
    @current_user.invoices.new
  end

  def shippers
    shipper_settings = ShipperSetting.near [@current_user.user_setting.latitude,
      @current_user.user_setting.longitude], Settings.max_distance, order: false
    shippers = Shipper.users_by_user_setting shipper_settings
    ActiveModelSerializers::SerializableResource.new shippers,
      each_serializer: Users::ListShipperSerializer, scope: {current_user: @current_user}
  end

  private
  def user_setting
    @user_setting ||= @current_user.user_setting
  end
end
