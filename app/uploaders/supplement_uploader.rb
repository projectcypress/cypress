class SupplementUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  storage :file
  process :set_content_type

  def store_dir
    "#{APP_CONSTANTS['file_upload_root']}/products/#{model.id}"
  end

  def extension_white_list
    %w[doc docx xls xlsx ppt pptx jpg jpeg pdf png zip]
  end
end
