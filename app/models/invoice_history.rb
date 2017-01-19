class InvoiceHistory < ApplicationRecord
  belongs_to :invoice

  enum status: [:init, :waiting, :shipping, :shipped, :finished, :cancel]
end
