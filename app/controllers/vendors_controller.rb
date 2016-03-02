class VendorsController < ApplicationController
  before_action :set_vendor, only: [:show, :update, :destroy, :edit]

  # breadcrumbs
  add_breadcrumb 'Dashboard', :vendors_path
  add_breadcrumb 'Add Vendor',  :new_vendor_path,  only: [:new, :create]
  add_breadcrumb 'Edit Vendor', :edit_vendor_path, only: [:edit, :update]

  def index
    @vendors = Vendor.all.order(:updated_at => :desc)
    respond_to do |f|
      f.html
      f.json { render json: @vendors }
    end
  end

  def show
    add_breadcrumb 'Vendor: ' + @vendor.name, :show_vendor_path
    @products = Product.where(vendor_id: @vendor.id).order_by(state: 'desc')
    respond_to do |f|
      f.html
      f.json { render json: @vendor }
    end
  end

  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new(vendor_params)
    @vendor.save!
    flash_comment(@vendor.name, 'success', 'created')
    respond_to do |f|
      f.json { redirect_to vendor_url(@vendor) } # TODO: this deals with API
      f.html { redirect_to root_path }
    end
  rescue Mongoid::Errors::Validations
    render :new
  end

  def edit
  end

  def update
    @vendor.update_attributes(vendor_params)
    @vendor.save!
    flash_comment(@vendor.name, 'info', 'edited')
    redirect_to root_path
  rescue Mongoid::Errors::Validations
    render :edit
  end

  def destroy
    @vendor.destroy
    flash_comment(@vendor.name, 'danger', 'removed')
    respond_to do |f|
      f.json { render nothing: true, status: 201 }
      f.html { redirect_to root_path }
    end
  end

  private

  def vendor_params
    params[:vendor].permit :name, :vendor_id, :name, :vendor_id, :url, :address, :state, :zip,
                           pocs_attributes: [:id, :name, :email, :phone, :contact_type, :_destroy]
  end
end
