class VendorsController < ApplicationController
  before_action :find_vendor, only: [:show, :update, :destroy]

  # breadcrumbs
  add_breadcrumb 'Dashboard', :vendors_path
  add_breadcrumb 'Add Vendor',  :new_vendor_path,  only: [:new, :create]
  add_breadcrumb 'Edit Vendor', :edit_vendor_path, only: [:edit, :update]

  def index
    # need to get all of the vendors that the user can see
    @vendors = Vendor.accessible_by(current_user).order(:updated_at => :desc)#Vendor.accessible_by(current_user).all.order(:updated_at => :desc)
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
    authorize! :create, Vendor
    @vendor = Vendor.new
  end

  def create
    authorize! :create, Vendor
    @vendor = Vendor.new(vendor_params)
    @vendor.save!
    current_user.add_role :owner, @vendor
    flash_vendor_comment(@vendor.name, 'success', 'created')
    respond_to do |f|
      f.json { redirect_to vendor_url(@vendor) } # TODO: this deals with API
      f.html { redirect_to root_path }
    end
  rescue Mongoid::Errors::Validations
    render :new
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end

  def update
    @vendor.update_attributes(vendor_params)
    @vendor.save!
    flash_vendor_comment(@vendor.name, 'info', 'edited')
    redirect_to root_path
  rescue Mongoid::Errors::Validations
    render :edit
  end

  def destroy
    @vendor.destroy
    flash_vendor_comment(@vendor.name, 'danger', 'removed')
    respond_to do |f|
      f.json { render nothing: true, status: 201 }
      f.html { redirect_to root_path }
    end
  end

  private

  def authorize_vendor(vendor)
    authorize! :manage, vendor if params[:action] != :show
    authorize! :read, vendor if params[:action] == :show
  end

  def find_vendor
    @vendor = Vendor.find(params[:id])
    authorize_vendor(@vendor)
  end

  def vendor_params
    params[:vendor].permit :name, :vendor_id, :name, :vendor_id, :url, :address, :state, :zip,
                           pocs_attributes: [:id, :name, :email, :phone, :contact_type, :_destroy]
  end

  # def set_flash_errors(vendor)
  #   flash[:notice_type] = 'warning'
  #   flash[:notice] = 'POCs ' + vendor.errors.get(:pocs).first unless vendor.errors.messages[:pocs].nil?
  #   flash[:notice] = vendor.errors.get(:name).first unless vendor.errors.messages[:name].nil?
  # end

  # action_type (string) describes what just happended to the vendor. should be past tense
  def flash_vendor_comment(vendor_name, notice_type, action_type)
    flash[:notice] = "Vendor '#{vendor_name}' was #{action_type}."
    flash[:notice_type] = notice_type
  end
end
