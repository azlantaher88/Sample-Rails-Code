class Person < ApplicationRecord
  # == Extensions ===========================================================

  attr_writer :email
  attr_writer :phone

  date_flag :deleted_at
  date_flag :searchable_at
  
  # == Constants ============================================================

  FIXED_ATTRIBUTES = %w[
    name
    email
    phone
  ].freeze
  
  # == Properties ===========================================================
  
  # == Relationships ========================================================

  has_many :reported_people
  has_many :reports,
    through: :reported_people
  
  # == Callbacks ============================================================

  before_validation :redact_email
  before_validation :redact_phone
  
  # == Validations ==========================================================

  validate :validate_minimum_requirements
  
  # == Scopes ===============================================================

  scope :with_phone, -> (phone) { 
    where(phone_h: Hasher.phone(phone))
  }

  scope :with_email, -> (email) {
    where(email_h: Hasher.email(email))
  }

  scope :with_fname, -> (fname) {
    where("substring(name from '([^\s]+)') ILIKE ?","%#{fname}%")
  }

  scope :with_lname, -> (lname) {
    where("substring(name from '\s(.*)') ILIKE ?","%#{lname}%")
  }


  # == Class Methods ========================================================

  def self.fixed_attributes
    @fixed_attributes ||= Set.new(FIXED_ATTRIBUTES)
  end
  
  def self.search_by_email(email)
    report = Report.where("content ->> 'person-email' ILIKE ?","#{email}%").first
    unless report.nil?
      report.reported_people.map{|_| _.person }
    else
      []
    end
  end

  def self.search_by_phone(phno)
    report = Report.where("content ->> 'person-phone' ILIKE ?","%#{phno}%").first
    unless report.nil?
      report.reported_people.map{|_| _.person }
    else
      []
    end
  end

  # == Instance Methods =====================================================

  def description
    [
      self.name,
      self.email_r,
      self.phone_r
    ].find(&:present?)
  end

  def description?
    self.phone_r? or self.email_r? or self.name?
  end

  def email
    @email or self.email_r
  end

  def phone
    @phone or self.phone_r
  end

protected
  def redact_email
    return if (@email.blank? or @email_redacted)

    self.email_h = Hasher.email(@email)
    @email = self.email_r = Redactor.email(@email)

    @email_redacted = true
  end

  def redact_phone
    return if (@phone.blank? or @phone_redacted)

    self.phone_h = Hasher.phone(@phone)
    @phone = self.phone_r = Redactor.phone(@phone)

    @phone_redacted = true
  end

  def validate_minimum_requirements
    return if (self.description?)

    self.errors.add(:name, "is required")
  end
end
