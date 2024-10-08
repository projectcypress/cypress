# frozen_string_literal: true

class SupplementUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "#{APP_CONSTANTS['file_upload_root']}/products/#{model.id}"
  end

  def extension_allowlist
    %w[doc docx xls xlsx ppt pptx jpg jpeg pdf png zip]
  end
end
