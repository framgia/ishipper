class Supports::Shipper::Shippers < Supports::User
  def initialize args
    @current_user = args[:current_user]
    @list_shippers = args[:shippers]
  end

  def shippers
    @shippers ||= list_shippers
  end

  def base_shippers
    @base_shippers ||= base_list_shippers
  end

  private
  def shippers_near_by
    @shipper_settings ||= ShipperSetting.near([user_setting.latitude,
      user_setting.longitude], Settings.max_distance, order: false).includes shipper: [:user_setting]
  end

  def shipper_settings
    if @list_shippers
      @list_shippers.includes(:user_invoices, user_setting: [:shipper]).collect do |shipper|
        shipper.shipper_setting
      end
    else
      shippers_near_by
    end
  end

  def base_list_shippers
    shipper_settings.collect do |shipper_setting|
      Supports::User.new(user: shipper_setting.shipper).base_user
      # Supports::Shipper::Shipper.new(shipper: shipper_setting.shipper).shipper
    end.to_json
  end

  def list_shippers
    shipper_settings.collect do |shipper_setting|
      support_shipper = Supports::Shipper::Shipper.new current_user: @current_user,
        shipper: shipper_setting.shipper
      support_user = Supports::User.new user: shipper_setting.shipper

      shipper = support_user.base_user
      shipper[:actions] = support_shipper.actions
      shipper[:favorite_user] = support_shipper.favorite_user
      shipper[:number_finished_invoice] = support_shipper.number_finished_invoice
      shipper[:number_all_invoice] = support_shipper.number_all_invoice
      shipper
    end
  end
end
