class NewsItem
  dummy :headline do
    Faker::Lorem.sentence(3, true, 4)
  end

  dummy :content do
    (rand(5) + 1).times.collect do
      Faker::Lorem.sentence(12, true, 12)
    end.join(' ')
  end

  dummy :user
end
