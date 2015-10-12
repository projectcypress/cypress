class PointOfContact

  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  embedded_in :vendor

  validates_presence_of :name, message: "Point of Contacts must have names."
  validates_uniqueness_of :name, scope: :vendor, message: "Point of Contact names must be unique."

  field :name, type: String
  field :email, type: String
  field :phone, type: String
  field :contact_type, type: String

end