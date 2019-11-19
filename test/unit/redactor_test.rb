require_relative '../test_helper'

class RedactorTest < ActiveSupport::TestCase
  def test_redact_email
    assert_mapping(
      'test@example.com' => 't**t@e*****e.com',
      'test@ab.com' => 't**t@a*.com',
      'test@q.com' => 't**t@q.com',
      't@x.com' => 't@x.com',
      'test@subdomain.example.com' => 't**t@s*******n.e*****e.com',
      'junk' => 'j**k',
      'junk@com' => 'j**k@com'
    ) do |email|
      Redactor.email(email)
    end
  end

  def test_redact_phone
    assert_mapping(
      '416-555-1212' => '416-5**-1212',
      '416-5**-1212' => '416-5**-1212',
      '555-1212' => '5**-1212',
      '5**-1212' => '5**-1212',
      '12345678901234' => '1**45678901234'
    ) do |phone|
      Redactor.phone(phone)
    end
  end

  def test_redact_license
    assert_mapping(
      'ABCD012' => 'A**D012'
    ) do |license|
      Redactor.license(license)
    end
  end
end
