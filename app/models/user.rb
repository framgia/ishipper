class User < ApplicationRecord
  acts_as_token_authenticatable

  devise :database_authenticatable, :recoverable, :confirmable,
    :rememberable, :trackable, :validatable

  geocoded_by :current_location
  reverse_geocoded_by :latitude, :longitude, address: :current_location,
    if: :address_changed?
  after_validation :geocode, :reverse_geocode

  has_many :invoices, dependent: :destroy
  has_many :user_invoices, dependent: :destroy
  has_many :all_user_invoices, through: :user_invoices, source: :invoice
  has_many :active_reviews, class_name: "Review", foreign_key: "owner_id",
    dependent: :destroy
  has_many :passive_reviews, class_name: "Review", foreign_key: "recipient_id",
    dependent: :destroy
  has_many :active_notifications, class_name: "Notification",
    foreign_key: "owner_id", dependent: :destroy
  has_many :passive_notifications, class_name: "Notification",
    foreign_key: "recipient_id", dependent: :destroy
  has_many :invoice_histories

  enum status: [:unactive, :actived, :block_temporary, :blocked]
  enum role: ["admin", "shop", "shipper"]

  ATTRIBUTES_PARAMS = [:phone_number, :name, :email, :address, :latitude,
    :longitude, :plate_number, :status, :role, :rate, :pin,
    :password, :password_confirmation, :current_password]

  validates :phone_number, uniqueness: true

  def email_required?
    false
  end

  def confirmation_required?
    false
  end

  def send_pin
    twilio_client = Twilio::REST::Client
      .new Rails.application.secrets.twilio_account_sid,
      Rails.application.secrets.twilio_auth_token
    if self.valid_phone_number?
      begin
        # pin = SecureRandom.urlsafe_base64[0..7]
        pin = "12345678"
        self.update_attributes pin: pin
        twilio_client.messages.create to: "#{self.phone_number}",
          from: "#{Settings.from_phone_number}", body: I18n.t("your_pin", pin: pin)
        rescue => e
        # Neu SDT khong ho tro thi tam thoi cho active, Loi la : Twilio::REST::RequestError
        # TODO
        self.activate
        return true
        true
      end
    else
      false
    end
  end

  def current_user? user
    self == user
  end

  def activate
    self.actived!
    # self.pin = nil
    return self.save
  end

  def reset_password params={}
    check = if check_pin params[:pin]
      self.password = params[:password]
      self.password_confirmation = params[:password_confirmation]
      self.pin = nil
      self.save
    else
      false
    end
    check
  end

  def check_pin pin
    return self.pin == pin
  end

  def valid_phone_number?
    lookup_client = Twilio::REST::LookupsClient
      .new Rails.application.secrets.twilio_account_sid,
       Rails.application.secrets.twilio_auth_token
    begin
      response = lookup_client.phone_numbers.get self.phone_number
      response.phone_number
      rescue => e
      return false
    end
  end
end
