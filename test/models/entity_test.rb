require_relative '../test_helper'

class EntityTest < ActiveSupport::TestCase
  def test_create_defaults
    entity = Entity.create

    assert_created entity

    assert_equal false, entity.published?
    assert_equal false, entity.deleted?

    assert_equal 0, entity.identifiers.count
    assert_equal 0, entity.identifier_types.count
  end

  def test_create_dummy
    entity = Entity.create_dummy

    assert_created entity
  end

  def test_create_requirements
    entity = Entity.create

    # NOTE: So far this Entity is pretty much a blank slate, it serves as a
    #       container for the various identifiers that may or may not be
    #       present.
    assert_created entity
  end

  def test_description_populated
    identifier_type = IdentifierType.create!(
      code: 'name',
      label: 'Name',
      record_type: 'Entity',
      priority: 1
    )

    entity = Entity.create!

    assert_nil entity.description

    entity.identifiers.create!(
      identifier_type: identifier_type,
      content: 'Test Name'
    )

    assert_equal 'Test Name', entity.description_from_identifiers

    entity.save!

    assert_equal 'Test Name', entity.description
  end

  def test_description_with_priority
    high_priority_type = IdentifierType.create!(
      code: 'name',
      label: 'Name',
      record_type: 'Entity',
      priority: 1
    )

    low_priority_type = IdentifierType.create!(
      code: 'hair',
      label: 'Hair',
      record_type: 'Entity'
    )

    entity = Entity.create!

    assert_nil entity.description

    entity.identifiers.create!(
      identifier_type: low_priority_type,
      content: 'Shaggy Hair'
    )

    assert_equal 'Shaggy Hair', entity.description_from_identifiers

    entity.identifiers.create!(
      identifier_type: high_priority_type,
      content: 'Test Name'
    )

    assert_equal 'Test Name', entity.description_from_identifiers

    entity.save!

    assert_equal 'Test Name', entity.description

    entity.identifiers.create!(
      identifier_type: low_priority_type,
      content: 'Sideburns'
    )

    assert_equal 'Test Name', entity.description_from_identifiers
  end
end
