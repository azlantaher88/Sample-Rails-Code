require_relative '../test_helper'

class IdentifierTypeTest < ActiveSupport::TestCase
  def test_create_defaults
    identifier_type = IdentifierType.create(
      code: 'hairstyle',
      label: 'Hair Style',
      record_type: 'Person'
    )

    assert_created identifier_type
  end

  def test_create_requirements
    identifier_type = IdentifierType.create

    assert_not_created identifier_type
    assert_errors_on identifier_type, :code, :label, :record_type
  end

  def test_valid_redactor_option
    identifier_type = IdentifierType.create(
      code: 'license_plate',
      label: 'License Plate',
      record_type: 'Vehicle',
      redaction_method: 'license'
    )

    assert_created identifier_type
  end

  def test_invalid_redactor_option
    identifier_type = IdentifierType.create(
      code: 'hairstyle',
      label: 'Hair Style',
      record_type: 'Person',
      redaction_method: 'hair'
    )

    assert_not_created identifier_type
    assert_errors_on identifier_type, :redaction_method
  end
end
