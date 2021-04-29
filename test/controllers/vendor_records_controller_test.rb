# frozen_string_literal: true

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

    # vendor patient for second bundle
    @bundle2 = FactoryBot.create(:executable_bundle, active: false)
    @patient_bundle2 = FactoryBot.create(:vendor_test_patient,
                                         bundleId: @bundle2._id, correlation_id: @vendor.id)
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

  test 'should not crash when showing vendor patients with bundle specified' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :index, params: { vendor_id: @vendor.id, bundle_id: @bundle2._id }
      assert_response :success

      get :index, params: { vendor_id: @vendor.id, bundle_id: @bundle._id }
      assert_response :success
    end
  end

  test 'should show correct vendor patients with bundle specified' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :index, params: { vendor_id: @vendor.id, bundle_id: @bundle2.id }
      assert response.body.include?(vendor_record_path(vendor_id: @vendor.id, id: @patient_bundle2.id)), 'response should include bundle2 vendor patient link'
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

  test 'should create vendor patients with default bundle' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = Patient.count

      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'good_patient_upload.zip')
      good_zip = fixture_file_upload(filename, 'application/zip')
      perform_enqueued_jobs do
        post :create, params: { file: good_zip, vendor_id: @vendor.id, bundle_id: @bundle._id }
        assert_redirected_to({ controller: 'records', action: 'index', bundle_id: @bundle._id }, 'response should redirect to index')

        # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
        get :index, params: { vendor_id: redirect_to_url.split('/')[-2] }
        assert_equal orig_patient_count + 1, Patient.count
      end
    end
  end

  test 'should create vendor patients for alternate bundle' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = @vendor.patients.select { |p| p.bundleId == @bundle2.id.to_s }.count

      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'good_patient_upload.zip')
      good_zip = fixture_file_upload(filename, 'application/zip')
      perform_enqueued_jobs do
        post :create, params: { file: good_zip, vendor_id: @vendor.id, bundle_id: @bundle2.id }
        assert_redirected_to({ controller: 'records', action: 'index', bundle_id: @bundle2.id }, 'response should redirect to index')

        # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
        get :index, params: { vendor_id: redirect_to_url.split('/')[-2], bundle_id: @bundle2.id }
        @vendor.reload
        later_patient_count = @vendor.patients.select { |p| p.bundleId == @bundle2.id.to_s }.count
        assert_equal orig_patient_count + 1, later_patient_count
      end
    end
  end

  test 'should create vendor patients and shift to match bundle' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = Patient.count

      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'good_patient_shift.zip')
      good_zip = fixture_file_upload(filename, 'application/zip')
      perform_enqueued_jobs do
        post :create, params: { file: good_zip, vendor_id: @vendor.id, bundle_id: @bundle._id }
        assert_redirected_to({ controller: 'records', action: 'index', bundle_id: @bundle._id }, 'response should redirect to index')

        # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
        get :index, params: { vendor_id: redirect_to_url.split('/')[-2] }
        assert_equal orig_patient_count + 1, Patient.count
      end
    end
  end

  test 'should delete vendor patients' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      # Create a couple new patients just for this so nothing else is screwed up
      @patient2 = FactoryBot.create(:vendor_test_patient,
                                    bundleId: @bundle._id, correlation_id: @vendor.id)
      @patient3 = FactoryBot.create(:vendor_test_patient,
                                    bundleId: @bundle._id, correlation_id: @vendor.id)

      # destroy_multiple is expecting patient IDs
      orig_patient_count = Patient.count # This should check the DB directly...?
      post :destroy_multiple, params: { patient_ids: "#{@patient2.id},#{@patient3.id}", vendor_id: @vendor.id }
      assert_redirected_to(root_path, 'response should redirect to index')

      # cannot use redirect url since it is root, use vendor id instead
      get :index, params: { vendor_id: @vendor.id }
      assert response.body.include?('Deleted 2 patients'), 'response should include patient deletions'
      assert_equal orig_patient_count - 2, Patient.count
    end
  end

  test 'should not delete fake vendor patients' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      # Create a couple new patients just for this so nothing else is screwed up
      @patient2 = FactoryBot.create(:vendor_test_patient,
                                    bundleId: @bundle._id, correlation_id: @vendor.id)

      # destroy_multiple is expecting patient IDs
      orig_patient_count = Patient.count # This should check the DB directly...?
      post :destroy_multiple, params: { patient_ids: "#{@patient2.id},FAKE", vendor_id: @vendor.id, bundle_id: @bundle.id }
      assert_redirected_to(root_path, 'response should redirect to index')

      # cannot use redirect url since it is root, use vendor id instead
      get :index, params: { vendor_id: @vendor.id }
      assert response.body.include?('1 patient could not be deleted.'), 'response should indicate number of undeleted patients'
      assert_equal orig_patient_count - 1, Patient.count
    end
  end

  test 'should show error for any non-CDA file upload' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = Patient.count
      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'half_fail_patient_upload.zip')
      half_fail_file = fixture_file_upload(filename, 'application/zip')
      perform_enqueued_jobs do
        post :create, params: { file: half_fail_file, vendor_id: @vendor.id, bundle_id: @bundle._id }
        assert_redirected_to vendor_records_path(vendor_id: @vendor.id, bundle_id: @bundle._id), 'response should redirect to index'
        # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
        get :index, params: { vendor_id: redirect_to_url.split('/')[-2], bundle_id: @bundle._id }

        tracker = Tracker.where('options.vendor_id' => @vendor.id.to_s, 'options.original_filename' => 'half_fail_patient_upload.zip').first
        # This is a CDA Schema error
        assert tracker.log_message.last.include? '303:0: ERROR: Element'
        assert_equal orig_patient_count + 1, Patient.count
      end
    end
  end

  test 'should show error for a file that fails import' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      orig_patient_count = Patient.count
      filename = Rails.root.join('test', 'fixtures', 'artifacts', 'full_fail_patient_upload.zip')
      half_fail_file = fixture_file_upload(filename, 'application/zip')
      perform_enqueued_jobs do
        post :create, params: { file: half_fail_file, vendor_id: @vendor.id, bundle_id: @bundle._id }
        assert_redirected_to vendor_records_path(vendor_id: @vendor.id, bundle_id: @bundle._id), 'response should redirect to index'
        # use vendor id from redirect_to_url "http://test.host/vendors/#{id}/records"
        get :index, params: { vendor_id: redirect_to_url.split('/')[-2], bundle_id: @bundle._id }

        tracker = Tracker.where('options.vendor_id' => @vendor.id.to_s, 'options.original_filename' => 'full_fail_patient_upload.zip').first
        # This is an error message returned from patient import when realmCode is in the wrong place
        assert tracker.log_message.last.include? 'This element is not expected'
        assert_equal orig_patient_count, Patient.count
      end
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

  test 'should get patients by measure' do
    # do this for all users with vendor access
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, params: { vendor_id: @vendor.id }
      get :by_measure, xhr: true, params: { vendor_id: @vendor, measure_id: @bundle.measures.first.hqmf_id, bundle_id: @bundle.id }
      assert_template :by_measure
      assert_response :success, "#{@user.email} should have access to vendor patients by measure"
      assert assigns(:patients)
      assert assigns(:source)
      assert assigns(:bundle)
    end
  end
end
