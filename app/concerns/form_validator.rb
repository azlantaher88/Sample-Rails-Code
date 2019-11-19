class FormValidator
  # == Properties ===========================================================

  attr_reader :errors
  
  # == Constants ============================================================
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(form)
    @expander = FormExpander.new(form)
  end

  def validate!(data)
    @errors = { }

    keys_present = data.keys.select do |key|
      data[key].present?
    end

    (@expander.required - keys_present).each do |missing|
      @errors[missing] = "%s is required." % [
        @expander[missing]['name'] || missing
      ]
    end

    (keys_present - @expander.keys).each do |invalid|
      @errors[invalid] = "No question named #{invalid} found."
    end
  end

  def valid?
    !@errors or @errors.empty?
  end
end
