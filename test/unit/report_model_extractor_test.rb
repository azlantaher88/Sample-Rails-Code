require_relative '../test_helper'

class ReportModelExtractorTest < ActiveSupport::TestCase
  def test_null_extract
    report = a Report

    extractor = ReportModelExtractor.new(report)

    assert_no_difference %w[ Person.count Vehicle.count ] do
      extractor.extract!
    end
  end

  def test_form_full
    form = form_full

    assert_created form_full
  end

  def test_vehicle_extract
    form = a Form
  end

  def test_person_extract
  end

protected
  def form_full
    Form.create_from_file!(
      json: fixture_expand_path('form_full.json'),
      published: true,
      name: 'Test Form'
    )
  end
end
