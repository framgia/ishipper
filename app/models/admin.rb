class Admin < ApplicationRecord
  devise :database_authenticatable, :recoverable,
    :rememberable, :trackable, :validatable

  ATTRIBUTES_PARAMS = [:name, :email, :address, :password, :password_confirmation,
    :avatar, :phone_number]
  UPDATE_ATTRIBUTES_PARAMS = [:name, :email, :address, :password,
    :password_confirmation, :avatar, :phone_number]
end
