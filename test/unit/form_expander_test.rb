require_relative '../test_helper'

class FormExpanderTest < ActiveSupport::TestCase
  def test_expand_simple
    data = rails_hash(
      title: 'Example',
      id: 'test'
    )

    expected = {
      'title' => 'Example',
      'id' => 'test',
      'type' => 'question'
    }

    assert_equal expected, FormExpander.new(data).to_h
  end

  def test_expand_with_prefix
    data = {
      title: 'Example',
      id: 'test',
      data: [
        {
          title: 'Nested',
          id: '-nested',
          if: '-if'
        }
      ]
    }

    expected = {
      'title' => 'Example',
      'id' => 'test',
      'data' => [
        {
          'title' => 'Nested',
          'id' => 'test-nested',
          'if' => 'test-if',
          'type' => 'question'
        }
      ],
      'type' => 'question'
    }

    assert_equal expected, FormExpander.new(data).to_h
    
    assert_equal expected, FormExpander.new(expected).to_h
  end

  def test_expand_with_automatic_id
    data = {
      title: 'Example',
      id: 'test',
      data: [
        {
          title: 'Nested'
        }
      ]
    }

    expected = {
      'title' => 'Example',
      'id' => 'test',
      'data' => [
        {
          'title' => 'Nested',
          'id' => 'test-nested',
          'type' => 'question'
        }
      ],
      'type' => 'question'
    }

    assert_equal expected, FormExpander.new(data).to_h
  end

  def test_expand_with_target
    data = {
      title: 'Person',
      id: 'person',
      target: 'person',
      type: 'section',
      data: [
        {
          title: 'Name'
        }
      ]
    }

    expected = {
      'title' => 'Person',
      'id' => 'person',
      'target' => 'person',
      'type' => 'section',
      'data' => [
        {
          'title' => 'Name',
          'id' => 'person-name',
          'type' => 'question',
          'target' => 'person'
        }
      ]
    }

    assert_equal expected, FormExpander.new(data).to_h
    assert_equal expected, FormExpander.new(expected).to_h

    assert_equal %w[ person ], FormExpander.new(data).targets
    assert_equal %w[ person-name ], FormExpander.new(data).target_fields('person')
  end

  def test_flatten
    data = {
      title: 'Person',
      id: 'person',
      target: 'person',
      type: 'section',
      data: [
        {
          title: 'Name',
          required: true
        },
        {
          title: 'Age'
        },
        {
          title: 'Selection',
          type: 'select',
          data: [
             {
              title: 'Yes'
             },
             {
              title: 'No'
             }
          ]
        }
      ]
    }

    expected = {
      'person-name' => {
        'title' => 'Name',
        'required' => true,
        'id' => 'person-name',
        'type' => 'question',
        'target' => 'person'
      },
      'person-age' => {
        'title' => 'Age',
        'id' => 'person-age',
        'type' => 'question',
        'target' => 'person'
      },
      'person-selection' => {
        'title' => 'Selection',
        'type' => 'select',
        'data' => [
          {
            'title' => 'Yes',
            'id' => 'person-selection-yes',
            'type' => 'selection',
            'target' => 'person'
          },
          {
            'title' => 'No',
            'id' => 'person-selection-no',
            'type' => 'selection',
            'target' => 'person'
          }
        ],
        'id' => 'person-selection',
        'target' => 'person'
      },
      'person-selection-yes' => {
        'title' => 'Yes',
        'id' => 'person-selection-yes',
        'target' => 'person',
        'type' => 'selection'
      },
      'person-selection-no' => {
        'title' => 'No',
        'id' => 'person-selection-no',
        'target' => 'person',
        'type' => 'selection'
      }
    }

    expander = FormExpander.new(data)

    assert_equal %w[ person-name ], expander.required
    assert_equal(
      %w[
        person-name
        person-age
        person-selection
        person-selection-yes
        person-selection-no
      ],
      expander.keys
    )

    assert_equal expected, expander.flatten
  end

protected
  def rails_hash(data)
    ActiveSupport::HashWithIndifferentAccess.new(data)
  end
end
