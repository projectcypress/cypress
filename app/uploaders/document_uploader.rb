class DocumentUploader < CarrierWave::Uploader::Base
	storage :file

	def store_dir
		"#{APP_CONFIG['file_upload_root']}/test_executions/#{model.id}"   
  end


end