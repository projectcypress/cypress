require 'breadcrumbs'
class ApplicationController < ActionController::Base
  layout :layout_by_resource
  include Breadcrumbs
  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'
  before_filter :configure_permitted_parameters, if: :devise_controller?

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
    logger.error(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    logger.error(exception)
    @exception = exception
    respond_to do |format|
         format.html { render template: 'errors/error_500', layout: 'layouts/application', status: 500 }
         format.all { render nothing: true, status: 500}
       end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name << :last_name << :telephone << :terms_and_conditions
  end
end
