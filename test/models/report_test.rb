require_relative '../test_helper'

class ReportTest < ActiveSupport::TestCase
  def test_create_defaults
    version = a FormVersion

    report = Report.create(
      version: version,
      content: {
        question_1: 'Answer'
      },
      tags: %w[ #tag1 #tag2 tag3 ]
    )

    assert_created report

    assert_equal [ report.id ], report.form.report_ids
    assert_equal [ report.id ], report.version.report_ids

    assert_equal %w[ #tag1 #tag2 ], report.tags
    assert_equal %w[ #tag1 #tag2 ], report.admin_tags
    assert_equal %w[ ], report.response_tags

    assert_equal [ ], Report.tagged('test').collect(&:id)
    assert_equal [ report.id ], Report.tagged('#tag1').collect(&:id)
    assert_equal [ ], Report.tagged('#tag1', 'tag3').collect(&:id)
    assert_equal [ report.id ], Report.tagged('#tag2', '#tag1').collect(&:id)

    assert report.ident?
    assert_equal 12, report.ident.length
  end

  def test_create_requirements
    report = Report.create

    assert_not_created report
    assert_errors_on report, :form, :version
  end

  def test_create_dummy
    report = Report.create_dummy

    assert_created report

    assert_equal [ report.id ], report.form.report_ids
    assert_equal [ report.id ], report.version.report_ids
  end

  def test_create_with_admin_tags
    version = a FormVersion

    report = Report.create(
      version: version,
      content: {
        question_1: 'Answer'
      },
      admin_tags: 'tag1 tag3,tag1'
    )

    assert_created report

    assert_equal %w[ #tag1 #tag3 ], report.tags
    assert_equal %w[ #tag1 #tag3 ], report.admin_tags
  end
end
