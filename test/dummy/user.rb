class User
  dummy :email do
    Faker::Internet.email
  end

  dummy :password do
    SecureRandom.uuid
  end

  dummy :signup_request do
    'This is an example signup request'
  end
end
