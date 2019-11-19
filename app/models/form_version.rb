class FormVersion < ApplicationRecord
  # == Extensions ===========================================================

  date_flag :published_at
  
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Relationships ========================================================

  belongs_to :form

  has_many :reports
  
  # == Callbacks ============================================================

  before_validation :expand_content
  
  # == Validations ==========================================================

  validates :form,
    presence: true

  validates :version,
    presence: true

  validates :content,
    presence: true
  
  # == Scopes ===============================================================

  # == Class Methods ========================================================

  def self.current
    published.order(published_at: :desc).first
  end
  
  # == Instance Methods =====================================================

  def reload_from!(path, attributes = nil)
    self.content = JSON.load(File.open(path))
    self.attributes = attributes
    self.save!
  end

  def expander
    @expander ||= FormExpander.new(self.content)
  end

  def reducer
    @reducer ||= FormReducer.new(self.content)
  end

  def required
    self.expander.required
  end

  def required?(key)
    self.expander.required.include?(key)
  end

protected
  def expand_content
    return unless (self.content?)

    self.content = self.expander.to_h
  end
end
