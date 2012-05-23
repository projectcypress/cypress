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
  field :email, :type => String, :null => false
  field :encrypted_password, :type => String, :null => false
  field :first_name, :type => String, :null => false
  field :last_name, :type => String, :null => false
  field :phone, :type => String, :null => false

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
end