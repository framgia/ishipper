class CreateInvoiceHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :invoice_histories do |t|
      t.string :attribute_name
      t.string :before_value
      t.string :after_value
      t.integer :user_id, foreign_key: true
      t.references :invoice, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
