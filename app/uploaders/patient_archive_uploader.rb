class PatientArchiveUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  storage :file
  process :set_content_type

  def store_dir
    "#{Cypress::AppConfig['file_upload_root']}/product_test/#{model.id}"
  end

  def uploaded_filename
    file.filename
  end
end
