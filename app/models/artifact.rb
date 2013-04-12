class Artifact

	include Mongoid::Document
	include Mongoid::Timestamps

	mount_uploader :file, DocumentUploader
  belongs_to :test_execution

	field :content_type, type: String
	field :file_size, type: Integer

	before_save :update_asset_attributes

	def is_archive?
		self.content_type == "application/zip" || File.extname(self.file.uploaded_filename) == ".zip"
	end

	def file_names
		file_names = []
		if is_archive?
			Zip::ZipFile.open(file.path) do |zipfile|
				file_names = zipfile.entries.collect{|entry| entry.name}
			end
		else
			file_names = [file.uploaded_filename]
		end
		file_names
	end

	def file_count
		count = 0
		if is_archive?
			Zip::ZipFile.open(file.path) do |zipfile|
				count = zipfile.entries.count
			end
		else
			count= 1
		end
		count
	end

	def get_file(name)
		if self.is_archive?
			return get_archived_file(name)
		elsif file.uploaded_filename == name
			return file.read
		end
	end

	def get_archived_file(name)
		data = nil
		Zip::ZipFile.open(file.path) do |zipfile|
			data = zipfile.read(name)
		end
		data
	end

	def each_file(&block)
		if self.is_archive?
		Zip::ZipFile.open(file.path) do |zipfile|
		zipfile.entries.each do |entry|
		  data = zipfile.read(entry.name)	
				yield entry.name, data
			end
		end

		else
			yield file.uploaded_filename, file.read
		end
	end
  
  private
  
  def update_asset_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end
end