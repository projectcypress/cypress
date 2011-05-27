class Vendor

  include Mongoid::Document

  embeds_many :tests, class_name: "Run", inverse_of: :vendor

  field :name, type: String
  field :poc, type: String
  field :tel, type: String
  field :proctor, type: String

end