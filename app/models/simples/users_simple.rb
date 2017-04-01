class Simples::UsersSimple < Simples::BaseSimple
  attr_accessor :id, :phone_number, :name, :email, :address, :role, :rate,
    :current_location, :latitude, :longitude, :online

  def current_location
    user_setting.current_location
  end

  def latitude
    user_setting.latitude
  end

  def longitude
    user_setting.longitude
  end

  def online
    @object.online?
  end

  private
  def user_setting
    @user_setting ||= @object.user_setting
  end
end
