class User < ApplicationRecord
  acts_as_token_authenticatable

  devise :database_authenticatable, :recoverable, :confirmable,
    :rememberable, :trackable, :validatable

  geocoded_by :current_location
  reverse_geocoded_by :latitude, :longitude, address: :current_location,
    if: :address_changed?
  after_validation :geocode, :reverse_geocode

  has_many :invoices, dependent: :destroy
  has_many :active_reviews, class_name: "Review", foreign_key: "owner_id",
    dependent: :destroy
  has_many :passive_reviews, class_name: "Review", foreign_key: "recipient_id",
    dependent: :destroy
  has_many :active_notifications, class_name: "Notification",
    foreign_key: "owner_id", dependent: :destroy
  has_many :passive_notifications, class_name: "Notification",
    foreign_key: "recipient_id", dependent: :destroy

  enum status: [:unactive, :actived, :block_temporary, :blocked]

  def email_required?
    false
  end

  def confirmation_required?
    false
  end

  ATTRIBUTES_PARAMS = [:phone_number, :email, :address, :latitude,
    :longitude, :plate_number, :status, :role, :rate, :pin,
    :password, :password_confirmation]

  validates :phone_number, uniqueness: true

  def email_required?
    false
  end

  enum role: ["admin", "shop", "shipper"]

  def send_pin
    twilio_client = Twilio::REST::Client
      .new Rails.application.secrets.twilio_account_sid,
      Rails.application.secrets.twilio_auth_token
    pin = SecureRandom.urlsafe_base64[0..3]
    self.update_attributes pin: pin
    twilio_client.messages.create to: "#{self.phone_number}",
      from: "#{Settings.from_phone_number}", body: I18n.t("your_pin", pin: pin)
  end

  def current_user? user
    self == user
  end

  def activate
    self.actived!
    self.pin = nil
    return self.save
  end

  def reset_password params={}
    self.password = params[:password]
    self.password_confirmation = params[:password_confirmation]
    self.pin = nil
    return self.save
  end

  def check_pin pin
    return self.pin == pin
  end
end
