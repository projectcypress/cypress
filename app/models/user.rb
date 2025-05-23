# frozen_string_literal: true

class User
  include Mongoid::Document
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :timeoutable, :lockable, :invitable,
         :confirmable

  # confirmable
  field  :confirmation_token, type: String
  field  :confirmed_at, type: Time, default: proc { Settings.current.auto_confirm ? Time.now.in_time_zone : nil }
  field  :confirmation_sent_at, type: Time
  ## Database authenticatable
  field :email, type: String, default: ''
  field :unconfirmed_email
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  ## invitable
  field :invitation_token, type: String
  field :invitation_created_at, type: Time
  field :invitation_sent_at, type: Time
  field :invitation_accepted_at, type: Time
  field :invitation_limit, type: Integer

  has_many :test_executions, dependent: :nullify

  index(invitation_token: 1)
  index(invitation_by_id: 1)

  field :approved, type: Boolean, default: proc { Settings.current.auto_approve || false }

  validates :terms_and_conditions, acceptance: true, on: :create, allow_nil: false

  after_create :associate_points_of_contact
  after_create :assign_default_role

  attr_accessor :encrypted_umls_password

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if approved?
      super
    else
      :not_approved # Use whatever other message
    end
  end

  validate :password_complexity

  def password_complexity
    return unless password.present?

    # returns nil if no match, index of match otherwise
    lowcase = password =~ /^(?=.*[a-z])./
    upcase = password =~ /^(?=.*[A-Z])./
    num = password =~ /^(?=.*\d)./
    special = password =~ /^(?=.*\W)./
    unless [lowcase, upcase, num, special].compact.length >= 3
      errors.add :password, 'password must include at least 3 of the following: lowercase letters, uppercase letters, digits, special characters'
    end
    errors.add :password, 'email and password must be different' if password == email
  end

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  def associate_points_of_contact
    return unless Settings.current.auto_associate_pocs

    Vendor.where('points_of_contact.email' => email).by_updated_at.each do |vendor|
      add_role :vendor, vendor
    end
  end

  def assign_default_role
    dr = Settings.current.default_role
    add_role dr if dr.present?
  end

  def user_role?(*)
    has_role?(*) || Settings.current.ignore_roles
  end

  def assign_roles_and_email(params)
    self.roles = []
    add_role params[:role]
    self.email = params[:user][:email] if params[:user] && params[:user][:email]
    assignments = params[:assignments].values if params[:assignments]
    (assignments || []).each do |ass|
      add_role(ass[:role], Vendor.find(ass[:vendor_id]))
    end
    save
  end

  def unlock
    self.locked_at = nil
    self.failed_attempts = 0
    self.unlock_token = nil
    save
  end

  def will_save_change_to_email?; end
end
