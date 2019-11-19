require_relative '../test_helper'

class FormValidatorTest < ActiveSupport::TestCase
  def test_simple_validation
    form = {
      title: 'Sample Form',
      type: 'section',
      id: 'main',
      data: [
        {
          title: 'Name',
          required: true
        },
        {
          title: 'Age'
        }
      ]
    }

    data = {
      'main-name' => 'Example Name',
      'main-age' => 'Example Age'
    }

    validator = FormValidator.new(form)

    validator.validate!(data)

    assert_equal true, validator.errors.empty?
    assert_equal true, validator.valid?
  end

  def test_validation_failure_missing_required
    form = {
      title: 'Sample Form',
      type: 'section',
      id: 'main',
      data: [
        {
          title: 'Name',
          required: true
        },
        {
          title: 'Age'
        }
      ]
    }

    data = {
      'main-name': ''
    }

    validator = FormValidator.new(form)

    validator.validate!(data)

    assert_equal false, validator.valid?
    assert_equal %w[ main-name ], validator.errors.keys
  end
end
