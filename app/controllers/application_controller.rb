class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery

  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
  
end