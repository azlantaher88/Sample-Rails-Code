class Form < ApplicationRecord
  # == Exceptions ===========================================================

  class ImportError < Exception; end

  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Relationships ========================================================

  has_many :versions,
    class_name: 'FormVersion'

  has_many :reports
  
  # == Callbacks ============================================================

  before_validation :assign_slug

  # == Validations ==========================================================

  validates :name,
    presence: true
  
  # == Scopes ===============================================================
  
  # == Class Methods ========================================================

  def self.create_from_file!(options)
    form = self.new

    form.name = options[:name]

    yield(form) if (block_given?)

    form.save!

    version = form.import_version!(
      json: options[:json],
      version: options[:version] || '1.0',
      published: options[:published] || false
    )
    
    form
  end
  
  # == Instance Methods =====================================================

  def version(identifier)
    self.versions.find_by(version: identifier)
  end

  def import_version!(options)
    content =
      if (options[:json])
        JSON.load(File.open(options[:json]))
      else
        raise "Missing options"
      end

    self.versions.create!(
      content: content,
      version: options[:version] || Time.now.to_i.to_s,
      published: options[:published]
    )
  end

protected
  def assign_slug
    return if (self.slug? or !self.name?)

    self.slug = self.name.gsub(/\W/, ' ').gsub(/\s+/, '_').underscore
  end
end
