class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :address
      t.string :phone_number
      t.string :plate_number
      t.integer :status, default: 0
      t.string :role
      t.float :rate
      t.string :pin

      t.timestamps
    end
  end
end
