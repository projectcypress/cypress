class VendorsController < ApplicationController
  before_action :set_vendor, only: [:show, :update, :destroy, :edit]
  before_action :authorize_vendor, only: [:show, :update, :destroy, :edit]

  respond_to :html, :json, :xml

  # breadcrumbs
  add_breadcrumb 'Dashboard', :vendors_path
  add_breadcrumb 'Add Vendor',  :new_vendor_path,  only: [:new, :create]
  add_breadcrumb 'Edit Vendor', :edit_vendor_path, only: [:edit, :update]

  def index
    # get all of the vendors that the user can see
    @vendors = Vendor.accessible_by(current_user).order(:updated_at => :desc) # Vendor.accessible_by(current_user).all.order(:updated_at => :desc)
    respond_with(@vendors)
  end

  def show
    add_breadcrumb 'Vendor: ' + @vendor.name, :vendor_path
    @products = Product.where(vendor_id: @vendor.id).order_by(state: 'desc')
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
      f.json { render :nothing => true, :status => :created, :location => vendor_path(@vendor.id) }
      f.xml { render :nothing => true, :status => :created, :location => vendor_path(@vendor.id) }
    end
  rescue Mongoid::Errors::Validations
    respond_with(@vendor) do |f|
      f.html { render :new }
    end
  end

  def edit
  end

  def update
    @vendor.update_attributes(vendor_params)
    @vendor.save!
    flash_comment(@vendor.name, 'info', 'edited')
    respond_with(@vendor) do |f|
      f.html { redirect_to root_path }
    end
  rescue Mongoid::Errors::Validations
    respond_with(@vendor) do |f|
      f.html { render :edit }
    end
  end

  def destroy
    @vendor.destroy
    flash_comment(@vendor.name, 'danger', 'removed')
    respond_with(@vendor) do |f|
      f.html { redirect_to root_path }
    end
  end

  private

  def authorize_vendor
    authorize_request(@vendor)
  end

  def vendor_params
    params[:vendor].permit :name, :vendor_id, :url, :address, :state, :zip,
                           pocs_attributes: [:id, :name, :email, :phone, :contact_type, :_destroy]
  end
end
