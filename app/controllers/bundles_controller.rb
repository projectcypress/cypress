# frozen_string_literal: true

class BundlesController < ApplicationController
  include Api::Controller
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
