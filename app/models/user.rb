# The User model represents an account. Its primary utility is authentication and ownership of Vendors.
# In the future, Users may have different roles, such as ATCB or Vendor.

class User
  include Mongoid::Document

  has_many :vendors

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable
end