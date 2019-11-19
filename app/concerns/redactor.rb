module Redactor
  # == Constants ============================================================

  REDACTOR_OPTIONS = [
    :string,
    :email,
    :phone,
    :license
  ].freeze

  # == Module Methods =======================================================

  def self.options
    REDACTOR_OPTIONS
  end

  # == Mixin Methods ========================================================

  def string(string)
    string.gsub(/\A(.)(.+?)(.?)\z/) do |s|
      [
        $1,
        '*' * ($2 ? $2.length : 0),
        $3
      ].join
    end
  end

  def email(email)
    unless (email.match(/@/))
      return string(email)
    end

    email.scan(/[^@\.]+|[@\.]/).reverse.each_with_index.collect do |part, i|
      case (part)
      when '@', '.'
        part
      else
        case (i)
        when 0
          part
        else
          string(part)
        end
      end
    end.reverse.join
  end

  def phone(phone)
    digits = phone.gsub(/[^\d\*]/, '')

    case (digits.length)
    when 7
      '%s-%s' % [
        digits[0,1] + '**',
        digits[3,4]
      ]
    when 10
      '%s-%s-%s' % [
        digits[0,3],
        digits[3,1] + '**',
        digits[6,4]
      ]
    else
      phone.sub(/(\d)\d\d/, '\1**')
    end
  end

  def license(license)
    license.gsub(/[A-Za-z]+/) do |s|
      string(s)
    end
  end

  # == Module Methods =======================================================

  extend self
end
