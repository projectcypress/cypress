# frozen_string_literal: true

class VersionController < ApplicationController
  respond_to only: [:index]

  def index
    @version = { cypress_version => Cypress::Application::VERSION }
    respond_to do |format|
      format.xml { render xml: @version }
      format.json { render json: @version }
      format.all { render plain: @version }
    end
  end
end
