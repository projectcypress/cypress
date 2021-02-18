class PatientArchiveUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "#{APP_CONSTANTS['file_upload_root']}/product_test/#{model.id}"
  end

  def uploaded_filename
    file.filename
  end
end
