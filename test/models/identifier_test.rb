require_relative '../test_helper'

class IdentifierTest < ActiveSupport::TestCase
  def test_create_defaults
    entity = an Entity
  end

  def test_create_requirements
    identifier = Identifier.create

    assert_not_created identifier
    assert_errors_on identifier, :entity, :identifier_type, :content
  end

  def test_create_dummy
    identifier = Identifier.create_dummy

    assert_created identifier
  end

  def test_create_with_redaction
    entity = an Entity
    identifier_type = IdentifierType.create!(
      code: 'license',
      label: 'License',
      record_type: 'Entity',
      redaction_method: 'license'
    )

    identifier = Identifier.create!(
      entity: entity,
      identifier_type: identifier_type,
      content: 'ABCD 012'
    )

    assert_equal 'license', identifier.redaction_method
    assert_equal 'A**D 012', identifier.content_redacted
  end


  def test_create_without_redaction
    entity = an Entity
    identifier_type = IdentifierType.create!(
      code: 'name',
      label: 'Name',
      record_type: 'Entity'
    )

    identifier = Identifier.create!(
      entity: entity,
      identifier_type: identifier_type,
      content: 'Example Name'
    )

    assert_equal 'Example Name', identifier.content_redacted
  end
end
