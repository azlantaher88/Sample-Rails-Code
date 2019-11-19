# This is used to split out first-class model instances from the data stored
# within the form.

class ReportModelExtractor
  # == Instance Methods =====================================================

  def initialize(report)
    @report = report
  end

  def extract
    expander = @report.version.expander

    expander.targets.collect do |target|
      content = Hash[
        @report.content.slice(*expander.target_fields(target)).collect do |key, value|
          [ key.sub(/\A[^\-]+\-/, ''), value ]
        end
      ]

      case (target)
      when 'person'
        extract_model(Person, content)
      when 'vehicle'
        extract_model(Vehicle, content)
      end
    end.compact
  end

  def extract!
    models = self.extract

    ActiveRecord::Base.transaction do
      models.each do |model|
        model.save!
      end
    end

    models
  end

  def extract_model_attributes(model, data)
    attributes = {
      details: { }
    }

    fixed_attributes = model.fixed_attributes
    
    data.each do |key, value|
      if (fixed_attributes.include?(key))
        attributes[key] = value
      else
        attributes[:details][key] = value
      end
    end

    attributes
  end

protected
  def extract_model(model, data)
    model.new(extract_model_attributes(model, data))
  end
end
