class Vendor
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  resourcify

  scope :by_updated_at, -> { order(updated_at: :desc) }

  has_many :patients, dependent: :destroy, foreign_key: 'correlation_id', class_name: 'CQM::VendorPatient'
  embeds_many :points_of_contact, class_name: 'PointOfContact', cascade_callbacks: true

  accepts_nested_attributes_for :points_of_contact, allow_destroy: true, reject_if: ->(poc) { poc[:name].blank? }

  field :name, type: String
  field :vendor_id, type: String
  field :url, type: String
  field :address, type: String
  field :state, type: String
  field :zip, type: String
  field :preferred_code_systems, type: Hash, default: {}
  field :favorite_user_ids, type: Array, default: []
  field :vendor_patient_analysis, type: Hash, default: {}

  validates :name, presence: true, uniqueness: { message: 'Vendor name was already taken. Please choose another.' }

  def self.accessible_by(user)
    # if admin or atl or ignore_roles get them all
    # else get all vendors that the user is a owner or vendor on
    if user.user_role?(:admin) || user.user_role?(:atl)
      Vendor.all
    else
      vids = []
      user.roles.each do |role|
        vids << role.resource_id if role.resource_type == 'Vendor'
      end
      Vendor.in(_id: vids)
    end
  end

  def header_fields?
    url? || address? || !points_of_contact.empty?
  end
end
