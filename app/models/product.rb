class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :vendor, index: true, touch: true
  has_many :product_tests, dependent: :destroy
  # NOTE: more relationships must be defined

  field :name, type: String
  field :version, type: String
  field :description, type: String

  validates :name, presence: true
  validates :vendor, presence: true
  # methods must be added
end
