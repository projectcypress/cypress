class DocumentUploader < CarrierWave::Uploader::Base
	
	include CarrierWave::MimeTypes

	storage :file
  process :set_content_type

	def store_dir
		"#{APP_CONFIG['file_upload_root']}/test_executions/#{model.id}"   
  end

  def extension_white_list
    %w(xml zip)
  end


 def uploaded_filename 
    self.file.filename
 end 
end