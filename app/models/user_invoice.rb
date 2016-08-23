class UserInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :invoice

  has_many :user_invoice_histories

  enum status: [:init, :waiting, :shipping, :shipped, :finished, :cancel]
end
