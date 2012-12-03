class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_authorization!

	
	def index
		@jobs = Delayed::Job.where({queue: :admin, type: :vs_update})
	end


	def users
		@users = User.all
	end



	def import_bundle
		bundle = params[:bundle]
		importer = QME::Bundle::Importer.new
	  @bundle_contents = importer.import(bundle, params[:delete_existing])    

	end


	def update_value_sets
		@job = Delayed::Job.where({queue: :admin, type: :vs_update}).first

		unless @job

			job_log = AdminJob.new
			job_log.save
			
			payload = Cypress::ValuesetUpdateJob.new({username: params[:username],
																								password: params[:password],
																								clear: params[:clear],
																								status_reporter: job_log})

			@job= Delayed::Job.enqueue({payload_object:  payload, type: :vs_update, queue: :admin})
		end
		redirect_to :action=>:index
	end

	def job
		@job = AdminJob.find(params[:id])
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
