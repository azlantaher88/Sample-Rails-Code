class User < ApplicationRecord
  # == Extensions ===========================================================

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :confirmable,
    :lockable

  date_flag :confirmed_at
  date_flag :trusted_at
  date_flag :banned_at
  date_flag :rejected_at
  
  # == Constants ============================================================

  FLAGS = [
    :confirmed,
    :trusted,
    :banned,
    :rejected
  ].freeze

  ROLES = %w[
    admin
    support
    trusted
    registered
    guest
  ].freeze

  EFFECTIVE_ROLES = ROLES + %w[
    banned
    rejected
  ].freeze

  ROLE_DEFAULT = 'guest'.freeze

  ROLES_FOR_SELECT = ROLES.collect do |role|
    [ role.titleize, role ]
  end.freeze

  # == Properties ===========================================================
  
  # == Relationships ========================================================

  belongs_to :trusted_by_user,
    class_name: 'User'
  belongs_to :banned_by_user,
    class_name: 'User'
  belongs_to :referred_by_user,
    class_name: 'User'
  belongs_to :rejected_by_user,
    class_name: 'User'

  has_many :events,
    class_name: 'UserEvent'

  has_many :invitations,
    foreign_key: 'inviting_user_id'

  has_one :invitation,
    foreign_key: 'registered_user_id'

  has_many :user_mailing_lists
  has_many :mailing_lists,
    through: :user_mailing_lists

  ROLES.each do |role|
    next if (role == 'registered')

    scope role, -> {
      where(
        role: role,
        rejected_at: nil
      )
    }
  end
  
  # == Callbacks ============================================================
  
  # == Validations ==========================================================

  validates :password,
    length: {
      minimum: 8,
      message: 'must be at least eight characters long'
    },
    format: {
      with: /[^A-Za-z\s]/,
      message: 'must contain at least one number or symbol'
    },
    if: :password_given?

  validates :signup_request,
    presence: true,
    length: {
      minimum: 12,
      message: 'should contain more detail'
    }

  # == Scopes ===============================================================

  scope :registered, -> {
    where(
      role: nil,
      trusted_at: nil,
      rejected_at: nil
    )
  }
  
  # == Class Methods ========================================================

  def self.flags
    FLAGS
  end

  def self.roles
    ROLES
  end

  def self.role_default
    ROLE_DEFAULT
  end

  def self.roles_for_select
    ROLES_FOR_SELECT
  end
  
  # == Instance Methods =====================================================

  def admin?
    self.effective_role == 'admin'
  end

  def effective_role
    if (self.banned?)
      'banned'
    elsif (self.rejected?)
      'rejected'
    elsif (self.role)
      self.role
    elsif (self.trusted?)
      'trusted'
    elsif (self.confirmed?)
      'registered'
    else
      'guest'
    end
  end

  def password_given?
    self.password.present?
  end
end
