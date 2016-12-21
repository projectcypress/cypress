class User
  include Mongoid::Document
  rolify
  # Include default devise modules. Others available are:
  # :confirmable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :timeoutable, :lockable, :invitable,
         :confirmable

  # confirmable
  field  :confirmation_token, type: String
  field  :confirmed_at, type: Time, default: proc { Cypress::AppConfig['auto_confirm'] ? Time.now.in_time_zone : nil }
  field  :confirmation_sent_at, type: Time
  ## Database authenticatable
  field :email,              type: String, default: ''
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

  index(invitation_token: 1)
  index(invitation_by_id: 1)

  field :approved, type: Boolean, default: Cypress::AppConfig['auto_approve'] || false

  validates :terms_and_conditions, :acceptance => true, :on => :create, :allow_nil => false

  after_create :associate_points_of_contact
  after_create :assign_default_role

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  validate :password_complexity

  def password_complexity
    if password.present?
      # returns nil if no match, index of match otherwise
      lowcase = password =~ /^(?=.*[a-z])./
      upcase = password =~ /^(?=.*[A-Z])./
      num = password =~ /^(?=.*[\d])./
      special = password =~ /^(?=.*[\W])./
      unless [lowcase, upcase, num, special].compact.length >= 3
        errors.add :password, 'password must include at least 3 of the following: lowercase letters, uppercase letters, digits, special characters'
      end
      if password == email
        errors.add :password, 'email and password must be different'
      end
    end
  end

  def toggle_approved
    approved = !approved
    save
  end
  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  def associate_points_of_contact
    if Cypress::AppConfig['auto_associate_pocs']
      Vendor.where('points_of_contact.email' => email).each do |vendor|
        add_role :vendor, vendor
      end
    end
  end

  def assign_default_role
    dr = Cypress::AppConfig['default_role']
    add_role dr if dr
  end

  def user_role?(*args)
    has_role?(*args) || Cypress::AppConfig['ignore_roles']
  end
end
