# frozen_string_literal: true

class VersionController < ApplicationController
  respond_to only: [:index]

  def index
    @version = { 'version' => Cypress::Application::VERSION }
    respond_to do |format|
      format.xml { render xml: @version.to_xml(root: 'version') }
      format.json { render json: @version }
    end
  end
end
