# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register 'application/zip', :zip
Mime::Type.register 'text/xml', :xml

# Mime::Type.register 'application/vnd.api+json', :json_api
# ActionController::Renderers.add :json_api do |obj, options|
#   self.content_type ||= Mime[:json_api]
#   obj
# end
