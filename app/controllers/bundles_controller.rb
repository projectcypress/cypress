class BundlesController < ApplicationController
  def index
    Bundle.all
  end

  def show
    @bundle = Bundle.find(params)
  end

  def create
  end

  def destroy
    @bundle = Bundle.find(params)
    @bundle.destroy
  end
end
