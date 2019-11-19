require_relative '../test_helper'

class FormTest < ActiveSupport::TestCase
  def test_create_defaults
    form = Form.create(
      name: 'Test Form'
    )

    assert_created form
    
    assert_equal 0, form.versions.count
    assert_equal 0, form.reports.count

    assert_equal 'test_form', form.slug
  end

  def test_create_requirements
    form = Form.create

    assert_not_created form

    assert_errors_on form, :name
  end

  def test_create_dummy
    form = Form.create_dummy

    assert_created form

    assert_equal 0, form.versions.count
    assert_equal 0, form.reports.count
  end

  def test_import_version_json
    form = Form.create_dummy

    version = form.import_version!(
      json: fixture_expand_path('form_short.json'),
      version: '1a',
      published: true
    )

    assert_created version
    assert version.published?

    assert_equal '1a', version.version

    assert_equal_ids [ version.id ], form.version_ids
    assert_equal_ids [ version.id ], [ form.versions.current ]
  end

  def test_create_from_file_json
    form = Form.create_from_file!(
      json: fixture_expand_path('form_short.json'),
      version: '2',
      published: false
    ) do |form|
      form.name = 'Short Form'
    end

    assert_created form
    assert_equal 1, form.versions.count
    
    version = form.versions.first

    assert !version.published?

    assert_equal 'Short Form', form.name
    assert_equal '2', version.version
  end
end
