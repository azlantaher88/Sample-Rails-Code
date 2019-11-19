require_relative '../test_helper'

class FormFillerTest < ActiveSupport::TestCase
  def test_fields
    form = form_mixed
    version = form.versions.first

    filler = FormFiller.new(version)

    assert_equal %w[ person-name person-age person-hair person-locations ], filler.fields_all
    assert_equal %w[ person-name person-hair ], filler.fields_required

    assert_equal filler.fields_required, filler.fields_required & filler.fields_random
  end

  def test_fill_required
    form = form_mixed
    version = form.versions.first

    filler = FormFiller.new(version, :required)

    report = filler.report

    report.save!

    assert_created report

    assert_equal form.id, report.form_id
    assert_equal version.id, report.form_version_id
  end

  def test_fill_all
    form = form_mixed
    version = form.versions.first

    filler = FormFiller.new(version, :all)

    report = filler.report

    report.save!

    assert_created report

    assert_equal form.id, report.form_id
    assert_equal version.id, report.form_version_id

    assert report.content['person-locations-vehicle'].present?
  end

  def test_fill_random
    form = form_mixed
    version = form.versions.first

    filler = FormFiller.new(version, :random)

    report = filler.report

    report.save!

    assert_created report

    assert_equal form.id, report.form_id
    assert_equal version.id, report.form_version_id
  end

protected
  def form_mixed
    Form.create_from_file!(
      json: fixture_expand_path('form_mixed.json'),
      published: true,
      name: 'Mixed Content Form'
    )
  end
end
