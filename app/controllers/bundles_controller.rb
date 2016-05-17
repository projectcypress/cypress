class BundlesController < ApplicationController
  include API::Controller
  respond_to :xml, :json

  def index
    @bundles = Bundle.all
    respond_with(@bundles.to_a)
  end

  def show
    @bundle = Bundle.find(params['id'])
    respond_with(@bundle)
  end
end
