class Identifier
  dummy :entity
  dummy :identifier_type

  dummy :content do
    SecureRandom.uuid
  end
end
