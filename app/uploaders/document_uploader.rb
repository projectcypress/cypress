# frozen_string_literal: true

class DocumentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "#{APP_CONSTANTS['file_upload_root']}/test_executions/#{model.id}"
  end

  def extension_allowlist
    %w[xml zip]
  end

  def uploaded_filename
    file.filename
  end
end
