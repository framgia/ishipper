class Supports::Users < Supports::User

  def initialize args
    @current_user = args[:current_user]
    @users = args[:users]
  end

  def list_users
    @users.collect do |user|
      Supports::User.new(user: shipper_setting.shipper).base_user
    end
  end

end
