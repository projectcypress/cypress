require 'api'

class VendorsController < ApplicationController
  include API::Controller
  before_action :set_vendor, only: %i[show update destroy edit favorite preferences update_preferences]
  before_action :authorize_vendor, only: %i[show update destroy edit favorite preferences update_preferences]

  # breadcrumbs
  add_breadcrumb 'Dashboard', :vendors_path
  add_breadcrumb 'Add Vendor', :new_vendor_path, only: %i[new create]

  respond_to :js, only: %i[show favorite]

  def index
    # get all of the vendors that the user can see
    @vendors = Vendor.accessible_by(current_user).order(updated_at: :desc) # Vendor.accessible_by(current_user).all.order(:updated_at => :desc)
    respond_with(@vendors.to_a)
  end

  def show
    add_breadcrumb 'Vendor: ' + @vendor.name, :vendor_path
    @products_fav = @vendor.favorite_products(current_user)

    # paginate non-favorites
    products_nonfav = @vendor.products.ordered_for_vendors.reject { |p| (p.favorite_user_ids.include? current_user.id) }
    @nonfav_count = products_nonfav.count
    @products_nonfav = Kaminari.paginate_array(products_nonfav).page(params[:page]).per(5)
    @products = @vendor.products.ordered_for_vendors
    respond_with(@vendor)
  end

  def new
    authorize! :create, Vendor.new
    @vendor = Vendor.new
  end

  def create
    authorize! :create, Vendor.new
    @vendor = Vendor.new(vendor_params)
    @vendor.save!
    current_user.add_role :owner, @vendor
    flash_comment(@vendor.name, 'success', 'created')
    respond_with(@vendor) do |f|
      f.html { redirect_to root_path }
    end
  rescue Mongoid::Errors::Validations
    respond_with_errors(@vendor) do |f|
      f.html { render :new, status: :bad_request }
    end
  end

  def edit
    add_breadcrumb 'Vendor: ' + @vendor.name, :vendor_path
    add_breadcrumb 'Edit Vendor', :edit_vendor_path
  end

  def update
    add_breadcrumb 'Vendor: ' + @vendor.name, :vendor_path
    add_breadcrumb 'Edit Vendor', :edit_vendor_path
    @vendor.update(vendor_params)
    @vendor.save!
    flash_comment(@vendor.name, 'info', 'edited')
    respond_with(@vendor) do |f|
      f.html { redirect_to root_path }
    end
  rescue Mongoid::Errors::Validations
    respond_with_errors(@vendor) do |f|
      f.html { render :edit, status: :bad_request }
    end
  end

  def destroy
    @vendor.destroy
    flash_comment(@vendor.name, 'danger', 'removed')
    respond_with(@vendor) do |f|
      f.html { redirect_to root_path }
    end
  end

  def favorite
    user_id = current_user.id
    deleted_value = @vendor.favorite_user_ids.delete(user_id)
    @vendor.favorite_user_ids.push(user_id) if deleted_value.nil?
    @vendor.save!
    respond_with(@vendor)
  end

  def preferences
    add_breadcrumb 'Vendor: ' + @vendor.name, vendor_path(@vendor)
    add_breadcrumb 'Preferences', vendor_preferences_path(@vendor)
    # TODO: change to pull from Cypress app settings
    @vendor.preferred_code_systems = Settings.current.default_code_systems if @vendor.preferred_code_systems.empty?
    @vendor.save
  end

  def update_preferences
    # save preferences to vendor preferred_code_systems
    @vendor.preferred_code_systems = JSON.parse(params['vendor_preferences'])
    @vendor.save
    redirect_to vendor_path(@vendor)
  end

  private

  def authorize_vendor
    authorize_request(@vendor)
  end

  def vendor_params
    params[:vendor][:name]&.strip!
    params.require(:vendor).permit(:name, :vendor_id, :url, :address, :state, :zip,
                                   points_of_contact_attributes: %i[id name email phone contact_type _destroy])
  end
end
