class CreateInvoiceHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :invoice_histories do |t|
      t.string :name
      t.string :address_start
      t.float :latitude_start, limit: 25
      t.float :longitude_start, limit: 25
      t.string :address_finish
      t.float :latitude_finish, limit: 25
      t.float :longitude_finish, limit: 25
      t.string :delivery_time
      t.float :distance_invoice
      t.string :description
      t.float :price
      t.float :shipping_price
      t.integer :status
      t.float :weight
      t.string :customer_name
      t.string :customer_number
      t.integer :invoice_id
      t.integer :creater_id

      t.timestamps null: false
    end
  end
end
