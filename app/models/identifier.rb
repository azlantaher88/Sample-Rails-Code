class Identifier < ApplicationRecord
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Extensions ===========================================================
  
  # == Relationships ========================================================

  belongs_to :entity
  belongs_to :identifier_type
  
  # == Validations ==========================================================

  validates :content,
    presence: true

  validates :entity,
    presence: true
  
  validates :identifier_type,
    presence: true

  # == Callbacks ============================================================

  before_save :update_content_redacted
  
  # == Scopes ===============================================================
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def redaction_method
    self.identifier_type&.redaction_method
  end
  
protected
  def update_content_redacted
    self.content_redacted =
      if (self.content?)
        if (self.redaction_method)
          Redactor.send(self.redaction_method, self.content)
        else
          self.content
        end
      else
        nil
      end
  end
end
