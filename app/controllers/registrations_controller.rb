class RegistrationsController < Devise::RegistrationsController
  add_breadcrumb 'New Account', :new_user_registration_path, only: %i[new create]
  add_breadcrumb 'Edit User', :edit_user_registration_path, only: %i[edit update]
  add_breadcrumb 'Cancel Account', :cancel_user_registration_path, only: [:cancel]

  before_action :configure_permitted_parameters
  before_action :load_test_executions, only: %i[edit update]

  respond_to :js, only: [:edit]

  def new
    @title = 'Create Account'
    super
  end

  def edit
    @title = 'Edit User'
    super
  end

  protected

  def load_test_executions
    @all_executions = current_user.test_executions.order(%i[updated_at desc])
    @test_executions = Kaminari.paginate_array(@all_executions).page(params[:page]).per(15)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_and_conditions])
  end
end
