# frozen_string_literal: true

class PointOfContact
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  include Mongoid::Changeable

  embedded_in :vendor

  validates :name, presence: true, uniqueness: true

  field :name, type: String
  field :email, type: String
  field :phone, type: String
  field :contact_type, type: String

  before_save :check_for_email_changes
  after_save :associate_vendors
  before_destroy :remove_vendor_role

  def user
    User.find_by(email:) if email
  rescue StandardError
    # do nothing
  end

  def vendor_role?
    user&.user_role?(:vendor, vendor)
  end

  def remove_vendor_role
    user&.remove_role(:vendor, vendor)
  end

  def add_vendor_role
    user.add_role(:vendor, vendor) if user && !vendor_role?
  end

  private

  def associate_vendors
    add_vendor_role if Settings.current.auto_associate_pocs
  end

  def check_for_email_changes
    return unless changes['email']

    old_email, _new_email = changes['email']
    return unless !old_email.nil? && !old_email.delete(' ').empty?

    begin
      u = User.find_by(email: old_email)
      u.remove_role(:vendor, vendor)
    rescue StandardError
      # do nothing
    end
  end
end
