class User
  include Mongoid::Document

  has_and_belongs_to_many :products, index: true
  has_many   :product_tests
  has_many :patient_populations

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable

  # Database authenticatable
  field :email, :type => String
  field :encrypted_password, :type => String
  field :first_name, :type => String
  field :last_name, :type => String
  field :telephone, :type => String

  validates_presence_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_acceptance_of :terms_and_conditions, :allow_nil => false, :on => :create
  validate :password_complexity

  # Recoverable
  field :reset_password_token, :type => String
  field :reset_password_sent_at, :type => Time

  # Rememberable
  field :remember_created_at, :type => Time

  # Trackable
  field :sign_in_count, :type => Integer
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at, :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip, :type => String
  field :admin, type: Boolean
  field :approved, type: Boolean
  field :staff_role, type: Boolean
  field :disabled, type: Boolean

  #lockable
  field :failed_attempts, :type => Integer
  field :locked_at, :type => Time

   def grant_admin
    update_attribute(:admin, true)
    update_attribute(:approved, true)
  end

  def approve
    update_attribute(:approved, true)
  end

  def revoke_admin
    update_attribute(:admin, false)
  end

  private

  def password_complexity
    if password.present?
      lowcase = password.match(/^(?=.*[a-z])./) ? 1 : 0
      upcase = password.match(/^(?=.*[A-Z])./) ? 1 : 0
      num = password.match(/^(?=.*[\d])./) ? 1 : 0
      special = password.match(/^(?=.*[\W])./) ? 1 : 0
      if !(lowcase + upcase + num + special >= 3)
        errors.add :password, "password must include at least 3 of the following groups: lowercase letters, uppercase letters, digits, and special characters"
      end
      if password == email
        errors.add :password, "email and password must be different"
      end
    end
  end
end
