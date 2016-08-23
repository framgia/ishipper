class CreateUserInvoiceHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :user_invoice_histories do |t|
      t.string :attribute_name
      t.string :before_value
      t.string :after_value
      t.references :user_invoice, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
