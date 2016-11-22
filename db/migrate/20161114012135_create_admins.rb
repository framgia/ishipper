class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.string :name
      t.string :email
      t.string :address
      t.string :phone_number
      t.string :avatar

      t.timestamps
    end
  end
end
