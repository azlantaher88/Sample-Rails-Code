class FormVersion
  dummy :form
  dummy :version do
    SecureRandom.uuid
  end

  dummy :content do
    [
      {
        label: 'Question 1',
        id: 'question_1',
        responses: [
          'Yes', 'No'
        ]
      }
    ]
  end
end
