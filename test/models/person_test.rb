require_relative '../test_helper'

class PersonTest < ActiveSupport::TestCase
  def test_create_defaults
    person = Person.create(
      name: 'Test'
    )

    assert_created person

    assert_equal 0, person.reports.count
  end

  def test_create_requirements
    person = Person.create

    assert_not_created person

    assert_errors_on person, :name
  end

  def test_create_by_email
    person = Person.create(
      email: 'test@example.com'
    )

    assert_created person

    assert_equal_ids [ person ], Person.with_email('test@EXAMPLE.com')
  end

  def test_create_dummy
    person = Person.create_dummy

    assert_created person

    assert_equal 0, person.reports.count
  end

  def test_mangles_email
    person = Person.create_dummy(
      email: 'test@example.com'
    )

    assert_created person

    assert_equal 't**t@e*****e.com', person.email

    assert_equal_ids [ ], Person.with_phone('')
    assert_equal_ids [ ], Person.with_phone('test@example.com')

    person.save

    assert_equal_ids [ ], Person.with_phone('')
    assert_equal_ids [ ], Person.with_phone('test@example.com')
  end

  def test_mangles_phone
    person = Person.create_dummy(
      phone: '(416) 392-2489'
    )

    assert_created person

    assert_equal '416-3**-2489', person.phone

    assert_equal_ids [ ], Person.with_phone('')
    assert_equal_ids [ person ], Person.with_phone('416-392-2489')
  end
end
