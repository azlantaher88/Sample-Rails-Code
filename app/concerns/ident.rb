require 'securerandom'

module Ident
  extend ActiveSupport::Concern

  class_methods do
    def has_ident
      before_validation :assign_ident
    end
  end

  included do
    def assign_ident
      return if (self.ident?)

      self.ident = self.generate_ident
    end

    def generate_ident(length = 12)
      base = 'a'.ord

      length.times.map do
        (SecureRandom.random_number(26) + base).chr
      end.join('')
    end
  end
end
