class Vehicle < ApplicationRecord
  # == Extensions ===========================================================

  attr_writer :license

  date_flag :deleted_at
  date_flag :searchable_at
  
  # == Constants ============================================================

  FIXED_ATTRIBUTES = %w[
    license
  ].freeze

  # == Properties ===========================================================
  
  # == Relationships ========================================================

  has_many :reported_vehicles
  has_many :reports,
    through: :reported_vehicles
  
  # == Callbacks ============================================================

  before_validation :redact_license
  
  # == Validations ==========================================================

  validates :license_r,
    presence: true
  
  # == Scopes ===============================================================

  scope :with_license, -> (license) {
    where(license_h: Hasher.license(license))
  }
  scope :search_by_license_start, -> (license) {
    where("license_r ILIKE ?","#{license}%")
  }
  scope :search_by_license_end, -> (license) {
    where("license_r ILIKE ?","%#{license}")
  }
  
  # == Class Methods ========================================================
  
  def self.fixed_attributes
    @fixed_attributes ||= Set.new(FIXED_ATTRIBUTES)
  end

  # == Instance Methods =====================================================

  def description
    self.license_r
  end

  # REFACTOR: Create a redact class method to encapsulate this functionality
  def license
    @license or self.license_r
  end

  def license?
    @license.present? or self.license_r?
  end

protected
  def redact_license
    return unless (@license.present?)

    self.license_h = Hasher.license(@license)
    @license = self.license_r = Redactor.license(@license)
  end
end
