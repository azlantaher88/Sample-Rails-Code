class IdentifierType < ApplicationRecord
  # == Constants ============================================================

  RECORD_TYPES = %w[
    Vehicle
    Person
  ].freeze

  SELECTION_TYPES = {
    'multi' => 'Multiple',
    'one' => 'Pick One',
    '' => 'No Options'
  }.freeze
  
  # == Properties ===========================================================
  
  # == Extensions ===========================================================

  date_flag :published_at
  
  # == Relationships ========================================================

  has_many :identifiers
  has_many :entities,
    through: :identifiers
  has_many :options,
    class_name: 'IdentifierOption'
  
  # == Validations ==========================================================

  validates :code,
    presence: true

  validates :label,
    presence: true
  
  validates :record_type,
    presence: true

  validates :redaction_method,
    inclusion: {
      in: Redactor.options.map(&:to_s)
    },
    if: :redaction_method?

  # == Callbacks ============================================================
  
  # == Scopes ===============================================================

  scope :for_vehicles, -> {
    where(record_type: 'Vehicle')
  }

  scope :for_people, -> {
    where(record_type: 'Person')
  }
  
  # == Class Methods ========================================================

  def self.record_types
    RECORD_TYPES
  end

  def self.selection_types
    SELECTION_TYPES
  end
  
  # == Instance Methods =====================================================

  def state
    if (self.required?)
      'required'
    elsif (self.published?)
      'published'
    else
      'internal'
    end
  end
end
