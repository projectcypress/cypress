# frozen_string_literal: true

class Vendor
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  resourcify

  scope :by_updated_at, -> { order(updated_at: :desc) }

  has_many :products, dependent: :destroy
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
  field :preferred_ccn, type: String
  field :favorite_user_ids, type: Array, default: []
  field :vendor_patient_analysis, type: Hash, default: {}

  validates :name, presence: { allow_blank: false, message: "can't be blank" },
                   uniqueness: { message: 'Vendor name was already taken. Please choose another.' }
  validates :url, url: { allow_blank: true, message: 'is not a valid URL' }

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

  # This method does nothing more than attempt to cleanup a lot of data instead of making rails do it,
  # since rails is really bad at cleaning up quickly. Note that this bypasses the dependent => destroy
  # calls on product, product tests, etc, all the way down and does them manually. This means that
  # if any of those structures change then this code will need to be updated accordingly.
  def destroy
    product_tests = ProductTest.where(:product_id.in => product_ids).by_updated_at
    product_test_ids = product_tests.pluck(:_id)
    ProductTest.destroy_by_ids(product_test_ids)

    Product.in(id: product_ids).delete

    super
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      total = products.size
      if products_failing_count.positive?
        'failing'
      elsif products_passing_count == total && total.positive?
        'passing'
      elsif products_errored_count.positive?
        'errored'
      else
        'incomplete'
      end
    end
  end

  %w[passing failing errored incomplete].each do |product_state|
    define_method "products_#{product_state}_count" do
      product_counts = Rails.cache.fetch("#{cache_key}/product_counts") do
        products.includes(:product_tests).group_by(&:status)
      end

      product_counts.key?(product_state) ? product_counts[product_state].count : 0
    end
  end

  def header_fields?
    url? || address? || !points_of_contact.empty?
  end

  def favorite_products(current_user)
    products.ordered_for_vendors.where(favorite_user_ids: current_user.id)
  end
end
