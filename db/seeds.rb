User.create!(email: ENV.fetch('EMAIL'), password: ENV.fetch('PASSWORD'), password_confirmation: ENV.fetch('PASSWORD'))
