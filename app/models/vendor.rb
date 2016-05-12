class Vendor
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  resourcify

  default_scope -> { order(:updated_at => :desc) }

  has_many :products, :dependent => :destroy
  embeds_many :points_of_contact, class_name: 'PointOfContact', cascade_callbacks: true

  accepts_nested_attributes_for :points_of_contact, allow_destroy: true, reject_if: -> (poc) { poc[:name].blank? }

  field :name, type: String
  field :vendor_id, type: String
  field :url, type: String
  field :address, type: String
  field :state, type: String
  field :zip, type: String

  validates :name, presence: true, uniqueness: { message: 'Vendor name was already taken. Please choose another.' }

  def self.accessible_by(user)
    # if admin or atl or ignore_roles get them all
    # else get all vendors that the user is a owner or vendor on
    if user.has_role?(:admin) || user.has_role?(:atl) || APP_CONFIG.ignore_roles
      Vendor.all
    else
      vids = []
      user.roles.each do |role|
        vids << role.resource_id if role.resource_type == 'Vendor'
      end
      Vendor.in(_id: vids)
    end
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      total = products.count
      if products_failing.count > 0
        'failing'
      elsif products_passing.count == total && total > 0
        'passing'
      else
        'incomplete'
      end
    end
  end

  def products_passing
    Rails.cache.fetch("#{cache_key}/products_passing") do
      products.select { |product| product.status == 'passing' }
    end
  end

  def products_failing
    Rails.cache.fetch("#{cache_key}/products_failing") do
      products.select { |product| product.status == 'failing' }
    end
  end

  def products_incomplete
    Rails.cache.fetch("#{cache_key}/products_incomplete") do
      products.select { |product| product.status == 'incomplete' }
    end
  end
end
