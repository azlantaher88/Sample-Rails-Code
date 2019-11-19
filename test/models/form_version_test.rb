require_relative '../test_helper'

class FormVersionTest < ActiveSupport::TestCase
  def test_create_defaults
    form = a Form

    version = FormVersion.create(
      form: form,
      version: 1,
      content: [
        {
          title: 'Test'
        }
      ]
    )

    assert_created version

    assert_equal 1, form.versions.count
  end

  def test_create_requirements
    version = FormVersion.create

    assert_not_created version
    assert_errors_on version, :form, :version, :content
  end

  def test_create_dummy
    version = FormVersion.create_dummy

    assert_created version

    assert_equal false, version.published?
  end

  def test_expander_required
    form = a Form

    version = FormVersion.create(
      form: form,
      version: 1,
      content: [
        {
          title: 'Test',
          required: true
        },
        {
          title: 'Other'
        }
      ]
    )

    assert_created version

    assert_equal %w[ test ], version.required

    assert_equal true, version.required?('test')
    assert_equal false, version.required?('other')
  end

  def test_publish
    version = FormVersion.create_dummy

    assert_created version

    assert_equal false, version.published?

    version.published!

    assert_equal true, version.published?

    assert_equal_ids [ version ], version.form.versions.current
  end
end
