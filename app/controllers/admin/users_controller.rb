class Admin::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def resend_confirmation_email
  end

  def destroy
    User.find(params[:id]).destroy
  end

  def toggle_admin_role
    @user = User.find(params[:id])
    if @user.has_role? :admin
      @user.remove_role :admin
    else
      @user.add_role :admin
    end
  end

  def toggle_atl_role
    @user = User.find(params[:id])
    if @user.has_role? :atl
      @user.remove_role :atl
    else
      @user.add_role :atl
    end
  end

  def toggle_enabled
    @user = User.find(params[:id])
    @user.approved = !@user.approved
    @user.save
  end

  def assign_vender_role
    @user = User.find(params[:id])
    @user.add_role :vendor, Vendor.find(params[:vendor_id])
    @user.save
  end

  def remove_vender_role
    @user = User.find(params[:id])
    @user.remove_role :vendor, Vendor.find(params[:vendor_id])
    @user.save
  end
end
