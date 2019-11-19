class Report
  dummy :form,
    from: [ :version, :form ]

  dummy :version,
    inherit: {
      form_id: [ :form, :id ]
    }
end
