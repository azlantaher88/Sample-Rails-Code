class Report < ApplicationRecord
  # == Extensions ===========================================================

  has_ident

  date_flag :published_at
  date_flag :deleted_at
  
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Relationships ========================================================

  belongs_to :news_item
  belongs_to :form
  belongs_to :version,
    class_name: 'FormVersion',
    foreign_key: :form_version_id

  has_many :reported_people
  has_many :people,
    through: :reported_people

  has_many :reported_vehicles
  has_many :vehicles,
    through: :reported_vehicles
  
  # == Callbacks ============================================================

  before_validation :assign_form_from_version
  before_validation :assign_tags
  
  # == Validations ==========================================================

  validates :form,
    presence: true
  
  validates :version,
    presence: true

  validate :validate_form_requirements

  # == Scopes ===============================================================

  scope :unpublished, -> {
    where(published_at: nil)
  }
  
  # == Class Methods ========================================================

  def self.tagged(*tags)
    where('tags @> ARRAY[?]::varchar[]', tags.flatten)
  end
  
  # == Instance Methods =====================================================

  def to_param
    self.ident
  end

  def associated_records
    @associated_records ||= ReportModelExtractor.new(self).extract.select(&:valid?)
  end
  
  def associated_record_types
    self.associated_records.collect { |r| r.class.to_s }
  end

  def create_associated_records!(options = nil)
    self.associated_records.each do |record|
      case (record)
      when Person
        self.people << record
      when Vehicle
        self.vehicles << record
      end

      record.searchable!
    end

    self.save!
  end

  def alertable?
    self.published? and allow_alert?
  end

  def publishable?
    self.description.present? and allow_publish?
  end

  def will_create_person?
    associated_records.find do |record|
      record.is_a?(Person)
    end
  end

  def will_create_vehicle?
    associated_records.find do |record|
      record.is_a?(Vehicle)
    end
  end

  def form_validator
    @form_validator ||= FormValidator.new(self.version.content)
  end

  def reduced
    self.version.reducer.reduced(self)
  end

  def response_tags
    return [ ] unless (self.tags)

    self.tags.grep(/\A[^\#]/)
  end

  def admin_tags
    return [ ] unless (self.tags)

    self.tags.grep(/\A\#/)
  end

  def admin_tags=(list)
    self.tags ||= [ ]

    self.tags = self.tags.reject do |tag|
      tag[0, 1] = '#'
    end

    self.tags += [ list ].flatten.join(' ').split(/[\s,]+/).collect do |tag|
      case (tag[0,1])
      when '#'
        tag
      else
        '#' + tag
      end
    end
  end

  def declined?(option)
    content and content[option] and !!content[option].match(/-no\z/)
  end

  def allow_publish?
    !declined?('report-online')
  end

  def allow_alert?
    !declined?('report-booklet')
  end

protected
  def response_tags_extracted
    return unless (self.version)

    FormExpander.new(self.version.reducer.reduced(self)).flatten.values.collect do |node|
      node['tag']
    end.compact.uniq.sort
  end

  def assign_form_from_version
    return if (self.form)
    return unless (self.version)

    self.form = self.version.form
  end

  def validate_form_requirements
    return unless (self.version)

    self.form_validator.validate!(self.content || { })

    self.form_validator.errors.each do |field, error|
      self.errors.add(field, error)
    end
  end

  def assign_tags
    return unless (self.version)

    self.tags = (self.admin_tags + self.response_tags_extracted).uniq.sort
  end
end
