class Entity < ApplicationRecord
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Extensions ===========================================================

  date_flag :published_at
  date_flag :deleted_at
  
  # == Relationships ========================================================

  has_many :identifiers
  has_many :identifier_types,
    through: :identifiers
  
  # == Validations ==========================================================
  
  # == Callbacks ============================================================

  before_save :assign_description
  
  # == Scopes ===============================================================
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================
  
  def description_from_identifiers
    self.identifiers.joins(:identifier_type).order('identifier_types.priority DESC').first&.content_redacted
  end

protected
  def assign_description
    self.description = self.description_from_identifiers
  end
end
