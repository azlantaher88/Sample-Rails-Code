class Vehicle
  dummy :license do
    letters = ('A'..'Z').to_a

    '%s%03d' % [
      letters.shuffle[0,4].join,
      SecureRandom.random_number(1000)
    ]
  end
end
