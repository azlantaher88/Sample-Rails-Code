class Form
  dummy :name do
    Faker::Lorem.words(2).join(' ')
  end
end
