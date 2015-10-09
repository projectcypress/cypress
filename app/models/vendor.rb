class Vendor
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  has_many :products, dependent: :destroy
  embeds_many :pocs, class_name: 'PointOfContact'
  accepts_nested_attributes_for :pocs, allow_destroy: true, reject_if: -> (poc) { poc[:name].blank? }

  field :name, type: String
  field :vendor_id, type: String
  field :url, type: String
  field :address, type: String
  field :state, type: String
  field :zip, type: String

  validates :name, presence: true,
		   uniqueness: { message: 'Vendor name was already taken. Please choose another.' }

  # Methods should be used only for testing

  def failing_products
    5
  end

  def passing_products
    3
  end

  def incomplete_products
    1
  end

  def total_products
    8
  end
end
