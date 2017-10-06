class BundlesController < ApplicationController
  include API::Controller
  respond_to :xml, :json

  def index
    @bundles = Bundle.available.all
    respond_with(@bundles.to_a)
  end

  def show
    @bundle = Bundle.available.find(params['id'])
    respond_with(@bundle)
  end
end
