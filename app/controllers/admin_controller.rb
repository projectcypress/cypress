class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_authorization!

  add_breadcrumb 'Dashboard',"/"
	add_breadcrumb 'Admin',"/admin/index"
  add_breadcrumb "Valuesets", '', :only=>"valuesets"
  add_breadcrumb "Users", '', :only=>"users"

	def index
		@jobs = AdminValuesetJob.all
	end


	def users
		@users = User.all
	end



	def import_bundle
		bundle = params[:bundle]
		importer = QME::Bundle::Importer.new
	  @bundle_contents = importer.import(bundle, params[:delete_existing])    
    redirect_to :action=>:index
	end


	def update_value_sets
    if Bundle.count == 0
      flash[:errors]= "Cannot install/update valuesets until a bundle has been installed"
      redirect_to :action=>:index
      return
    end

		@job = AdminValuesetJob.where({}).ne({status: ["Waiting", "Running"]}).first

		unless @job

			@job = AdminValuesetJob.new
			@job.save
			@job.delay({attempts: Delayed::Worker.max_attempts-1, queue: :admin}).update_valuesets(params[:username],params[:password],params[:clear])

		end
		redirect_to :action=>:index
	end

  def job
    @job = AdminValuesetJob.find(params[:id])
  end

  def delete_job
    @job = AdminValuesetJob.find(params[:id])
    @job.delete
    flash[:message]= "Job (#{@job.id }) Deleted"
    redirect_to :action=>:index
  end

  def valuesets
    query = []
    search = params[:search] || ""
    if !search.empty?
      query = [{display_name:/#{search}/i},{oid:/#{search}/i}]
    end
    @page = params[:page] || 1
    @limit = 100
    @skip = (@page.to_i - 1) * @limit
  
    @valuesets = HealthDataStandards::SVS::ValueSet.or(query).skip(@skip).limit(@limit)
    @page_count =  (@valuesets.count.to_f / @limit.to_f).ceil
   

  end

  def valueset
    @valueset = HealthDataStandards::SVS::ValueSet.find(params[:id])
  end

  def promote
    toggle_privilidges(params[:username], params[:role], :promote)
  end

  def demote
    toggle_privilidges(params[:username], params[:role], :demote)
  end

  def disable
    user = User.by_username(params[:username]);
    disabled = params[:disabled].to_i == 1
    if user
      user.update_attribute(:disabled, disabled)
      if (disabled)
        render :text => "<a href=\"#\" class=\"disable\" data-username=\"#{user.username}\">disabled</span>"
      else
        render :text => "<a href=\"#\" class=\"enable\" data-username=\"#{user.username}\">enabled</span>"
      end
    else
      render :text => "User not found"
    end
  end


private

  def toggle_privilidges(username, role, direction)
    user = User.by_username username

    if user
      if direction == :promote
        user.update_attribute(role, true)
        render :text => "Yes - <a href=\"#\" class=\"demote\" data-role=\"#{role}\" data-username=\"#{username}\">revoke</a>"
      else
        user.update_attribute(role, false)
        render :text => "No - <a href=\"#\" class=\"promote\" data-role=\"#{role}\" data-username=\"#{username}\">grant</a>"
      end
    else
      render :text => "User not found"
    end
  end
  
  def validate_authorization!
    authorize! :admin, :users
  end

end
