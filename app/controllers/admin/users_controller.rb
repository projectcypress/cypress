require "securerandom"
module Admin
  class UsersController < ApplicationController
    before_filter ->{  authorize! :manage, User}
    add_breadcrumb 'Users', "/admin/users"
    def index
      # dont allow them to muck with their own account
      @users = User.excludes(:id => current_user.id).order_by(email:  1)
    end

    def create
      #make sure the terms and conditions are set to true for admin created users
      p = SecureRandom.hex + "!"
      @user = User.new(email: params[:email],approved: true,  terms_and_conditions: "1", password: p, password_confirmation: p)
      if @user.save
        @user.send_reset_password_instructions
        flash[:notice] = "Successfully created User."
        redirect_to admin_users_path
      else
        render :action => 'new'
      end
    end

    def reset_password
      @user = User.find(params[:id])
      @user.send_reset_password_instructions
      redirect_to admin_users_path
    end

    def toggle_approved
      @user = User.find(params[:id])
      @user.approved = !@user.approved
      @user.save
      redirect_to admin_users_path
    end

    def unlock
      @user = User.find(params[:id])
      @user.locked_at = nil
      @user.failed_attempts = 0;
      @user.unlock_token = nil
      @user.save
      redirect_to admin_users_path
    end

    def destroy
      @user = User.find(params[:id])
      if @user.destroy
        flash[:notice] = "Successfully deleted User."
        redirect_to admin_users_path
      end
    end

  end
end
