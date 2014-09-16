class User
  include Mongoid::Document

  has_and_belongs_to_many :products
  has_many   :product_tests
  has_many :patient_populations

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable
         
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
end