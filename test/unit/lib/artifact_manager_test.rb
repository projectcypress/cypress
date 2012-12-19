require 'test_helper'

class ArtifactManagerTest < ActiveSupport::TestCase




test "Should be able to store and find and delete files" do 
	test_execution = TestExecution.first

 
	file =  Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
	ids = Cypress::ArtifactManager.save_artifacts(file,test_execution)
	assert_equal 1, ids.length, "Should store 1 file"

	artifacts = Cypress::ArtifactManager.get_artifacts(ids)
	assert_equal 1, artifacts.length, "SHould return 1 artifact from get artifacts"

	Cypress::ArtifactManager.del_artifacts(ids)

	artifacts = Cypress::ArtifactManager.get_artifacts(ids)
	assert_equal 0, artifacts.length, "SHould return 0 artifacts after deleted"



end






end