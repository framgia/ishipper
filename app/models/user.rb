class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader

  devise :database_authenticatable, :recoverable, :confirmable,
    :rememberable, :trackable, :validatable, :registerable

  VALID_PHONE_REGEX = /\+84\d{9,10}\)*\z/

  geocoded_by :current_location
  reverse_geocoded_by :latitude, :longitude, address: :current_location,
    if: :address_changed?

  after_validation :geocode, :reverse_geocode
  has_one :user_setting, dependent: :destroy

  has_many :invoices, dependent: :destroy
  has_many :user_invoices, dependent: :destroy
  has_many :all_user_invoices, through: :user_invoices, source: :invoice
  has_many :active_reviews, class_name: Review.name, foreign_key: "owner_id",
    dependent: :destroy
  has_many :passive_reviews, class_name: Review.name, foreign_key: "recipient_id",
    dependent: :destroy
  has_many :active_notifications, class_name: Notification.name,
    foreign_key: "owner_id", dependent: :destroy
  has_many :passive_notifications, class_name: Notification.name,
    foreign_key: "recipient_id", dependent: :destroy
  has_many :owner_black_lists, class_name: BlackList.name,
    foreign_key: "owner_id", dependent: :destroy
  has_many :black_list_users, through: :owner_black_lists, source: :black_list_user
  has_many :owner_favorite_lists, class_name: FavoriteList.name,
    foreign_key: "owner_id", dependent: :destroy
  has_many :favorite_list_users, through: :owner_favorite_lists, source: :favorite_list_user
  has_many :passive_favorite_lists, class_name: FavoriteList.name,
    foreign_key: "favorite_list_user_id", dependent: :destroy
  has_many :passive_favorites, through: :passive_favorite_lists, source: :owner
  has_many :user_tokens, dependent: :destroy

  enum status: [:unactive, :actived, :block_temporary, :blocked]
  enum role: ["admin", "shop", "shipper"]

  scope :search_user, -> role, data {where("role = ? AND (phone_number = ? OR
    name LIKE ?)", role, data, "%#{data}%")}
  scope :is_online, -> {where online: true}

  ATTRIBUTES_PARAMS = [:phone_number, :name, :email, :address, :latitude,
    :longitude, :plate_number, :role, :password, :password_confirmation, :avatar,
    :current_location]

  UPDATE_ATTRIBUTES_PARAMS = [:name, :email, :address, :plate_number,
    :current_password, :receive_notification, :avatar, :current_location]

  validates :phone_number, uniqueness: true,
    format: {with: VALID_PHONE_REGEX}

  # validates :plate_number, uniqueness: true,
  #   length: {minimum: 8, maximum: 10}, allow_nil: true


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
        # twilio_client.messages.create to: "#{self.phone_number}",
        #   from: "#{Settings.from_phone_number}", body: I18n.t("your_pin", pin: pin)
        rescue => e
        return false
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
    self.pin = nil
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
    return self.pin == pin unless self.pin.nil?
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

  def to_param
    [id, name.parameterize].join("-")
  end
end
