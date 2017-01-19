namespace :db do
  desc "Import user"
  task users: [:environment] do
    users = []
    user_tokens = []
    user_settings = []
    users << User.new(
      name: "Shop 91",
      phone_number: "+841234567891",
      password: "12345678",
      password_confirmation: "12345678",
      email: "shop91@framgia.com",
      role: "Shop",
      status: "actived",
      rate: 3.5)

    users << User.new(
      name: "Shop 92",
      phone_number: "+841234567892",
      password: "12345678",
      password_confirmation: "12345678",
      email: "shop92@framgia.com",
      role: "Shop",
      status: "actived",
      rate: 2.5)

    users << User.new(
      name: "Shipper 97",
      phone_number: "+841234567897",
      password: "12345678",
      password_confirmation: "12345678",
      email: "shipper97@framgia.com",
      role: "Shipper",
      status: "actived",
      rate: 2.5)

    users << User.new(
      name: "Shipper 98",
      phone_number: "+841234567898",
      password: "12345678",
      password_confirmation: "12345678",
      email: "shipper98@framgia.com",
      role: "Shipper",
      status: "actived",
      rate: 2.5)

    number = 1234567860
    (1..20).each do |n|
      phone_number = number + n
      users << User.new(name: "Shipper #{n}",
        phone_number: "+84" + phone_number.to_s,
        password: "12345678",
        password_confirmation: "12345678",
        email: "shipper#{n}@framgia.com",
        role: "Shipper",
        status: "actived",
        rate: 3.5)
    end

    number = 1234567800
    (1..20).each do |n|
      phone_number = number + n
      users << User.new(name: "Shop #{n}",
        phone_number: "+84" + phone_number.to_s,
        password: "12345678",
        password_confirmation: "12345678",
        email: "shop#{n}@framgia.com",
        role: "Shop",
        status: "actived",
        rate: 3.5)
    end

    users << User.new(
      name: "Admin",
      phone_number: "+841234567890",
      password: "12345678",
      password_confirmation: "12345678",
      email: "Admin@framgia.com",
      role: "Admin",
      status: "actived",
      rate: 2.5)
    User.import users

    load_users = User.all
    load_users.each do |user|
      user_tokens << UserToken.new(authentication_token: user.phone_number,
        online: false, user_id: user.id, registration_id: user.phone_number)
      latitude = Faker::Number.between(0, 25000)
      latitude = 21 + latitude/1000000.0
      longitude = Faker::Number.between(825000, 865000)
      longitude = 105 + longitude/1000000.0
      role = user.role + "Setting" unless user.admin?
      user_settings << (UserSetting.new unread_notification: 0,
        latitude: latitude,
        longitude: longitude,
        role: role,
        user_id: user.id)
    end
    UserToken.import user_tokens
    UserSetting.import user_settings
  end
end
