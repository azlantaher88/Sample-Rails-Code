require 'digest/sha1'

module Hasher
  # == Module Methods =======================================================

  def digest(string)
    Digest::SHA256.hexdigest(string)
  end

  def email(email)
    digest(email.downcase.strip)
  end

  def phone(phone)
    digest(phone.gsub(/\D/, ''))
  end

  def license(license)
    digest(license.upcase.gsub(/[^A-Z0-9]/, ''))
  end
  
  extend self
end
