class Invoice < ApplicationRecord
  geocoded_by :address_start, latitude: :latitude_start,
    longitude: :longitude_start

  has_many :user_invoices, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :invoice_histories
  has_many :all_shipper, through: :user_invoices, source: :user

  belongs_to :user

  validates :name, presence: true
  validates :address_start, presence: true
  validates :address_finish, presence: true
  validates :delivery_time, presence: true
  validates :distance_invoice, presence: true
  validates :price, presence: true
  validates :shipping_price, presence: true
  validates :weight, presence: true
  validates :customer_name, presence: true
  validates :customer_number, presence: true
  validates :latitude_start, presence: true
  validates :longitude_start, presence: true
  validates :latitude_finish, presence: true
  validates :longitude_finish, presence: true


  ATTRIBUTES_PARAMS = [:name, :address_start, :address_finish, :delivery_time,
    :distance_invoice, :description, :price, :shipping_price, :weight,
    :customer_name, :customer_number, :latitude_start, :longitude_start,
    :latitude_finish, :longitude_finish]

  INVOICE_PARAMS = Set.new ["price", "shipping_price", "distance_invoice", "weight",
    "latitude", "longitude", "radius"]

  USER_PARAMS = Set.new ["latitude", "longitude", "distance"]

  REJECT_ATTRIBUTES = "id", "user_id", "creater_id", "updated_at", "created_at"

  enum status: [:init, :waiting, :shipping, :shipped, :finished, :cancel]

  scope :filter_by, -> column, min, max{
    where "#{column} BETWEEN ? AND ?", min, max}
  scope :search_invoice, -> search {where "name LIKE ?", "%#{search}%"}

  scope :invoice_by_status, -> status, user_id{
    where(id: UserInvoice.select(:invoice_id).where(status: status, user_id: user_id))
  }
  scope :order_by_time, -> {order created_at: :desc}

  class << self
    def filtering_column params
      params.slice :price, :shipping_price, :distance_invoice, :weight
    end

    def search params = {}
      valid_invoices = Invoice.joins("LEFT JOIN black_lists ON
        invoices.user_id = black_lists.owner_id")
        .where("black_lists.black_list_user_id != ? OR
        black_lists.black_list_user_id IS NULL", params[:black_list_user_id])
      if params[:user].present?
        invoices = valid_invoices.near [params[:user][:latitude],
        params[:user][:longitude]], params[:user][:distance] if
        params[:user][:latitude] && params[:user][:longitude] &&
        params[:user][:distance]

        invoices = Hash.new unless params[:user].keys.to_set.subset? USER_PARAMS

      elsif params[:invoice].present?
        invoices = valid_invoices

        invoices = valid_invoices.near [params[:invoice][:latitude],
          params[:invoice][:longitude]], params[:invoice][:radius] if
          params[:invoice][:latitude] && params[:invoice][:longitude] &&
          params[:invoice][:radius]

        Invoice.filtering_column(params[:invoice]).each do |key, value|
          invoices = invoices.filter_by key, value[:min], value[:max] if
            value[:min].present? && value[:max].present?
        end
        invoices = Hash.new unless params[:invoice].keys.to_set.subset?(INVOICE_PARAMS) &&
          invoices != valid_invoices
      end
      invoices = invoices.init if invoices.any?
      invoices
    end
  end
end
