require 'test_helper'

class QrdaUploadsControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  include VersionConfigHelper
  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:atl_user)
    FactoryBot.create(:user_user)
    FactoryBot.create(:other_user)
    User.find_by(email: 'other@test.com').update(approved: false)
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should be able to restrict access to unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, format: :json
      assert_response 401
    end
  end

  test 'should get index with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      get :index, format: :json
      assert_response :success, 'response should be OK on vendor index'

      assert_equal JSON.parse(response.body).size, possible_qrda_uploaders.size, 'there should be 1 entry for each possible_qrda_uploaders'
    end
  end

  test 'should create qrda upload with execution errors' do
    for_each_logged_in_user([USER]) do
      artifacts_before = Artifact.all.size

      possible_qrda_uploaders.each do |qrda_uploader|
        path_values = qrda_uploader['path'].split('/')
        filename = Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_templates.zip')
        zip_with_errors = fixture_file_upload(filename, 'application/zip')
        post :create, params: { format: :json, file: zip_with_errors, year: path_values[2], qrda_type: path_values[3], organization: path_values[4] }
        assert_response 201, 'response should be Created on test_execution creation'
        qrda_response = JSON.parse(response.body)
        assert_not_nil qrda_response
        assert qrda_response['execution_errors'].size.positive?
      end
      assert_equal artifacts_before, Artifact.all.size, 'no new artifacts should be in database'
    end
  end

  test 'should return a 404 for a validation that does not exist' do
    for_each_logged_in_user([USER]) do
      filename = Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_templates.zip')
      zip_with_errors = fixture_file_upload(filename, 'application/zip')
      post :create, params: { format: :json, file: zip_with_errors, year: '2222', qrda_type: 'qrdaI', organization: 'cms' }
      assert_response 404, 'Not Found for validator that does not exist'
    end
  end

  test 'should return an error with too many files' do
    for_each_logged_in_user([USER]) do
      # Reduce file limit to 1
      APP_CONSTANTS['zip_file_count_limit'] = 1
      qrda_uploader = possible_qrda_uploaders.first
      path_values = qrda_uploader['path'].split('/')
      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'full_fail_patient_upload.zip')
      good_zip = fixture_file_upload(filename, 'application/zip')
      post :create, params: { format: :json, file: good_zip, year: path_values[2], qrda_type: path_values[3], organization: path_values[4] }
      assert_response 201, 'response should be Created on test_execution creation'
      qrda_response = JSON.parse(response.body)
      assert_not_nil qrda_response
      assert qrda_response['execution_errors'][0]['message'].include? 'file count of 2 which exceeds upload limits of 20 MB and 1 files.'
    end
  end

  # XML

  test 'should get index with xml request' do
    for_each_logged_in_user([USER]) do
      artifacts_before = Artifact.all.size

      possible_qrda_uploaders.each do |qrda_uploader|
        path_values = qrda_uploader['path'].split('/')
        filename = Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_templates.zip')
        zip_with_errors = fixture_file_upload(filename, 'application/zip')
        post :create, params: { format: :xml, file: zip_with_errors, year: path_values[2], qrda_type: path_values[3], organization: path_values[4] }
        assert_response 201, 'response should be Created on test_execution creation'
        qrda_response = Hash.from_trusted_xml(response.body)
        assert_not_nil qrda_response
        assert qrda_response['qrda_upload']['execution_errors'].size.positive?
      end
      assert_equal artifacts_before, Artifact.all.size, 'no new artifacts should be in database'
    end
  end
end
