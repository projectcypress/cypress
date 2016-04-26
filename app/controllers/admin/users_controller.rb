module Admin
  class UsersController < ApplicationController
    before_action -> { authorize! :manage, User }
    add_breadcrumb 'Users', '/admin/users'


    def index
      # dont allow them to muck with their own account
      @users = User.excludes(id: current_user.id).order_by(email:  1)
    end

    def edit
      @user = User.find(params[:id])
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @user.roles = []
      @user.add_role params[:role].to_sym
      assignments = params[:assignments].values if params[:assignments]
      (assignments || []).each do |ass|
        @user.add_role(ass[:role], Vendor.find(ass[:vendor_id]))
      end
      @user.save
      flash[:notice] = 'Successfully updated user.'
      redirect_to_admin
    end

    def send_invitation
      User.invite!(email: params[:email])
      redirect_to_admin
    end

    def toggle_approved
      @user = User.find(params[:id])
      @user.approved = !@user.approved
      @user.save
      redirect_to_admin
    end

    def unlock
      @user = User.find(params[:id])
      @user.locked_at = nil
      @user.failed_attempts = 0
      @user.unlock_token = nil
      @user.save
      redirect_to_admin
    end

    def destroy
      @user = User.find(params[:id])
      if @user.destroy
        flash[:notice] = 'Successfully deleted User.'
        redirect_to_admin
      end
    end
    private
    def redirect_to_admin
      redirect_to "#{admin_path}#user_management"
    end
  end
end
