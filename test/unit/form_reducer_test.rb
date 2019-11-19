require_relative '../test_helper'

class FormReducerTest < ActiveSupport::TestCase
  def test_reduced_minimal
    form = form_mixed
    version = form.versions.first

    content = {
      'person-name' => 'Bad News',
      'person-hair' => 'person-hair-blonde'
    }

    report = Report.create(version: version, content: content)

    assert_created report

    reducer = FormReducer.new(version.content)

    expected = [
      {
        "title" => "Person",
        "id" => "person",
        "target" => "person",
        "type" => "section",
        "data" => [
          {
            "title" => "Name",
            "required" => true,
            "id" => "person-name",
            "type" => "question",
            "target" => "person"
          },
          {
            "title" => "Hair",
            "required" => true,
            "type" => "select",
            "data" => [
              {
                "title" => "Blonde",
                "id" => "person-hair-blonde",
                "type" => "selection",
                "target" => "person"
              }
            ],
            "id" => "person-hair", "target" => "person"
          }
        ]
      }
    ]

    assert_equal expected, reducer.reduced(report)
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
