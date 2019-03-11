require 'test_helper'

class VendorsRecordsControllerTest < ActionController::TestCase
  tests Vendors::RecordsController
  include ActiveJob::TestHelper
  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:atl_user)
    FactoryBot.create(:user_user)
    FactoryBot.create(:other_user)
    @vendor_user = FactoryBot.create(:vendor_user)

    @vendor = FactoryBot.create(:vendor_with_points_of_contact)
    @bundle = FactoryBot.create(:executable_bundle)
    @patient = FactoryBot.create(:vendor_test_patient,
                                 bundleId: @bundle._id, correlation_id: @vendor.id)

    add_user_to_vendor(@vendor_user, @vendor)
  end

  test 'should be able to restrict access to vendor records unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, params: { vendor_id: @vendor.id }
      assert_response 401
    end
  end

  test 'should not crash when showing vendor patients' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :index, params: { vendor_id: @vendor.id }
      assert_response :success
    end
  end

  test 'should not crash vendor patients when no bundles' do
    Bundle.all.destroy
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :index, params: { vendor_id: @vendor.id }
      assert_response :success
    end
  end

  test 'should create vendor patients' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = Patient.count

      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'good_patient_upload.zip')
      good_zip = fixture_file_upload(filename, 'application/zip')
      post :create, params: { file: good_zip, vendor_id: @vendor.id }
      assert_redirected_to vendor_records_path(vendor_id: @vendor.id), 'response should redirect to index'

      # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
      get :index, params: { vendor_id: redirect_to_url.split('/')[-2] }
      assert response.body.include?('Imported 1 patient'), 'response should include patient import'
      assert_equal orig_patient_count + 1, Patient.count
    end
  end

  test 'should show error for non-zip file upload' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      filename = Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'good.xml')
      xml_file = fixture_file_upload(filename, 'application/zip')
      post :create, params: { file: xml_file, vendor_id: @vendor.id }
      assert_redirected_to new_vendor_record_path, 'response should redirect back to patient upload'

      # use vendor id from redirect_to_url format "http://test.host/vendors/#{id}/records/new"
      get :new, params: { vendor_id: redirect_to_url.split('/')[-3] }
      reject_str = 'No valid patient file provided. Uploaded file must have extension .zip'
      assert response.body.include?(reject_str), 'response should include non-zip rejection'
    end
  end

  test 'should show error for any non-CDA file upload' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = Patient.count
      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'half_fail_patient_upload.zip')
      half_fail_file = fixture_file_upload(filename, 'application/zip')
      post :create, params: { file: half_fail_file, vendor_id: @vendor.id }
      assert_redirected_to vendor_records_path(vendor_id: @vendor.id), 'response should redirect to index'

      # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
      get :index, params: { vendor_id: redirect_to_url.split('/')[-2] }
      assert response.body.include?('Imported 1 patient'), 'response should include patient import'
      assert response.body.include?('&#39;brokendoug.xml&#39; had errors'), 'response should include errors'
      assert_equal orig_patient_count + 1, Patient.count
    end
  end

  test 'should be able to show vendor record' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, params: { vendor_id: @vendor.id, id: @patient }
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:record)
    end
  end

  test 'should be able to restrict access to vendor record show unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, params: { vendor_id: @vendor.id, id: @patient }
      assert_response 401
    end
  end
end