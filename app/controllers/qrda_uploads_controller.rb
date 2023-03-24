# frozen_string_literal: true

class QrdaUploadsController < ApplicationController
  include Api::Controller
  include VersionConfigHelper

  respond_to :xml, :json

  def index
    respond_with(possible_qrda_uploaders)
  end

  def create
    path = request.env['PATH_INFO'].split('.')[0]
    uploader = possible_qrda_uploaders.select { |u| u[:path] == path }.first
    if uploader
      upload_task = QrdaUploadTask.new(year: params['year'], qrda_type: params['qrda_type'], organization: params['organization'])
      test_execution = upload_task.execute(params['file'], current_user)
      uploader.execution_errors = test_execution.execution_errors
      cleanout_artifacts(test_execution.id)
      respond_with(uploader)
    else
      respond_to do |format|
        format.all  { render plain: "Validator not found. Visit '/qrda_validation' for listing of available validators", status: :not_found }
      end
    end
  end

  def cleanout_artifacts(test_execution_id)
    # Follow the same pattern as product_test deletion to remove artifacts
    test_executions = TestExecution.where(id: test_execution_id)
    test_execution_ids = test_executions.pluck(:_id)
    test_executions.delete
    Artifact.where(:test_execution_id.in => test_execution_ids).destroy
  end
end
