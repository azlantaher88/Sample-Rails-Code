class NewsItem < ApplicationRecord
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Extensions ===========================================================

  date_flag :published_at
  date_flag :deleted_at
  
  # == Relationships ========================================================

  belongs_to :user

  has_many :reports

  # == Validations ==========================================================

  validates :headline,
    presence: true

  validates :user,
    presence: true

  validate :validate_content_or_link

  # == Callbacks ============================================================
  
  # == Scopes ===============================================================
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

protected
  def validate_content_or_link
    unless (self.content? or self.link?)
      self.errors.add(:content, "Content or link is required")
    end
  end
end
