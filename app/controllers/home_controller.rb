class HomeController < ActionController::Base
  def index
    if current_user
      redirect_to :vendors
    else
      redirect_to :new_user_session
    end
  end
end
