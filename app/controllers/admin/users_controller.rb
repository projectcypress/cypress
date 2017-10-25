module Admin
  class UsersController < AdminController
    def index
      redirect_to admin_path(anchor: 'user_management')
    end

    def edit
      add_breadcrumb 'Edit Users', :edit_users_path
      @user = User.find(params[:id])
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @user.assign_roles_and_email(params)
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
      @user.unlock
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
