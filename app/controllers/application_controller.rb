class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery

  unless Rails.application.config.consider_all_requests_local 
    rescue_from Exception, with: :render_500
    rescue_from StandardError, with: :render_500
    rescue_from ArgumentError, with: :render_500
    rescue_from ActionView::Template::Error, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
  end

  protected


  class TypeNotFound < StandardError
  end
  
  rescue_from TypeNotFound do |exception|
    render :text => exception, :status => 500
  end




  def test_type(type)
    raise TypeNotFound.new if type.nil?
    type.camelize.constantize
  end


  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
  
  
  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    @error = exception
    respond_to do |format|
         format.html { render template: 'errors/error_500', layout: 'layouts/application', status: 500 }
         format.all { render nothing: true, status: 500}
       end
  end  
end