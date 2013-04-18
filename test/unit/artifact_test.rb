require 'test_helper'
class ArtifactTest  < ActiveSupport::TestCase


	test "should be able to tell if a file is an archive"   do 
		filename = "#{Rails.root}/test/fixtures/artifacts/qrda.zip"
		artifact = Artifact.new(file: File.new(filename))
		
		assert artifact.is_archive?, "should be able to tell it is an archive"
	end


	test "should be able to loop over archive files"  do
		expected = ["eh_test_results_bad.xml","eh_test_results.xml","qrda_cat3.xml","QRDA_CATIII_RI_AUG.xml"]
		reported = {}
		filename = "#{Rails.root}/test/fixtures/artifacts/qrda.zip"
		artifact = Artifact.new(file: File.new(filename))
		artifact.each_file do |name,data|
			reported[name] = data
		end
		assert_equal expected.sort, reported.keys.sort, "Archive should contain the correct files"

		root = "#{Rails.root}/tmp/test/artifacts"
		FileUtils.mkdir_p(root)
		filename = "#{root}/good_file_extension.xml"
		FileUtils.touch(filename)

		expected = ["good_file_extension.xml"]
		reported = {}
		artifact = Artifact.new(file: File.new(filename))
		artifact.each_file do |name,data|
			reported[name] = data
		end
		assert_equal expected, reported.keys, "Should loop on single xml document"

	end

	test "should be able to get contents for a given file name in an archive"  do
		filename = "#{Rails.root}/test/fixtures/artifacts/qrda.zip"
		artifact = Artifact.new(file: File.new(filename))
		data = artifact.get_archived_file("expected_results.json")
		# look at the first bit of the file data coming back and see if it matches what should be read
		assert data.index(%!{ "_id" : ObjectId( "507885343054cf8d83000002" )!) == 0, "should be able to read file from archive"
	end


	test "should only accept xml or zip files"  do 	
			root = "#{Rails.root}/tmp/test/artifacts"
			FileUtils.mkdir_p(root)

			['zip', 'xml'].each do |ext|
				filename = "#{root}/good_file_extension.#{ext}"
				FileUtils.touch(filename)
				artifact = Artifact.new(file: File.new(filename))
				assert artifact.save, "File should save with #{ext} extension"
			end


			#generate a random set of bad file extensions and try to save

			10.times do 
				ext = rand(36**3).to_s(36)
				unless (['zip', 'xml'].index(ext)) 
					filename = "#{root}/bad_file_extension.#{ext}"
					FileUtils.touch(filename)
					artifact = Artifact.new(file: File.new(filename))
					assert !artifact.save, "File should not save with un whitelisted extension #{ext}"
				end
			end	

			FileUtils.rm_rf(root)
	end


end
