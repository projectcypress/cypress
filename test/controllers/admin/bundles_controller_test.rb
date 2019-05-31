require 'test_helper'
module Admin
  class BundlesControllerTest < ActionController::TestCase
    include ActiveJob::TestHelper

    setup do
      FactoryBot.create(:admin_user)
      FactoryBot.create(:user_user)
      FactoryBot.create(:vendor_user)
      FactoryBot.create(:other_user)
      FactoryBot.create(:bundle)
      @vendor = FactoryBot.create(:vendor_with_points_of_contact)
      @static_bundle = FactoryBot.create(:static_bundle)
      FileUtils.rm_rf(APP_CONSTANTS['bundle_file_path'])
    end

    test 'should get index' do
      for_each_logged_in_user([ADMIN]) do
        get :index
        assert_redirected_to %r{/admin#bundles}
      end
    end

    test 'should deny access to index for non admins ' do
      for_each_logged_in_user([USER, OWNER, VENDOR]) do
        get :index
        assert_response 401
      end
    end

    test 'should get index without bundle install' do
      Bundle.destroy_all
      for_each_logged_in_user([ADMIN]) do
        get :index
        assert_redirected_to %r{/admin#bundles}
      end
    end

    test 'admin user should import new bundle successfully' do
      for_each_logged_in_user([ADMIN]) do
        orig_bundle_count = Bundle.count
        orig_measure_count = Measure.count
        orig_patient_count = Patient.count
        # Default Code Systems will be empty prior to loading bundle
        assert Settings.current.default_code_systems.empty?
        upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_4.zip'), 'application/zip')
        perform_enqueued_jobs do
          post :create, params: { file: upload }
          assert_performed_jobs 2
          assert_equal orig_bundle_count + 1, Bundle.count, 'Should have added 1 new Bundle'
          # Default Code Systems will not be empty after to loading bundle
          assert_not Settings.current.default_code_systems.empty?
          assert orig_measure_count < Measure.count, 'Should have added new measures in the bundle'
          assert orig_patient_count < Patient.count, 'Should have added new patients in the bundle'
        end
      end
    end

    test 'default_code_systems should update when import new bundle' do
      for_each_logged_in_user([ADMIN]) do
        orig_bundle_count = Bundle.count
        # Default Code Systems will be empty prior to loading bundle
        Settings.current.update(default_code_systems: { 'encounter' => ['2.16.840.1.113883.6.12'] })
        @vendor.preferred_code_systems['encounter'] = ['2.16.840.1.113883.6.12']
        @vendor.save
        assert_equal 1, Settings.current.default_code_systems['encounter'].size
        upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_4.zip'), 'application/zip')
        perform_enqueued_jobs do
          post :create, params: { file: upload }
          @vendor.reload
          assert_equal orig_bundle_count + 1, Bundle.count, 'Should have added 1 new Bundle'
          # Default Code Systems for encounter will now have 2 code systems
          assert_equal 2, Settings.current.default_code_systems['encounter'].size
          assert_equal 2, @vendor.preferred_code_systems['encounter'].size
          # The new code system will be added to the end
          assert_equal '2.16.840.1.113883.6.96', Settings.current.default_code_systems['encounter'].last
          assert_equal '2.16.840.1.113883.6.96', @vendor.preferred_code_systems['encounter'].last
        end
      end
    end

    test 'should deny access to import for non admin users ' do
      for_each_logged_in_user([USER, OWNER, VENDOR]) do
        upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_4.zip'), 'application/zip')
        post :create, params: { file: upload }
        assert_response 401
      end
    end

    test 'should not import file that is not a bundle' do
      for_each_logged_in_user([ADMIN]) do
        orig_count = Bundle.count

        upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip'), 'application/zip')
        assert_equal 0, BundleUploadJob.trackers.count, 'should be 0 trackers in db'
        perform_enqueued_jobs do
          post :create, params: { file: upload }
          assert_performed_jobs 1
          assert_equal 1, BundleUploadJob.trackers.count, 'should be 1 tracker in db'
          assert_equal :failed, BundleUploadJob.trackers.first.status, 'Status of tracker should be failed '
          assert_equal orig_count, Bundle.count, 'Should not have added new Bundle'
        end
      end
    end

    test 'should be able to change default bundle' do
      for_each_logged_in_user([ADMIN]) do
        flunk 'Should have at least 2 test bundles' if Bundle.count < 2

        active_bundle = Bundle.default
        inactive_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample

        post :set_default, params: { id: inactive_bundle._id }

        active_bundle.reload
        inactive_bundle.reload

        assert inactive_bundle.active, 'new default bundle should be active'
        assert_not active_bundle.active, 'old default bundle should no longer be active'
      end
    end

    test 'should not allow a non admin to change default bundle' do
      for_each_logged_in_user([USER, OWNER, VENDOR]) do
        flunk 'Should have at least 2 test bundles' if Bundle.count < 2
        inactive_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample

        post :set_default, params: { id: inactive_bundle._id }
        assert_response 401
      end
    end

    test 'should be able to remove bundle' do
      FactoryBot.create(:vendor_test_patient,
                        bundleId: @static_bundle._id, correlation_id: @vendor.id)
      for_each_logged_in_user([ADMIN]) do
        orig_bundle_count = Bundle.count
        orig_measure_count = Measure.count
        orig_patient_count = Patient.count
        orig_results_count = CQM::IndividualResult.count
        orig_vendor_patient_count = CQM::VendorPatient.count
        id = @static_bundle.id

        delete :destroy, params: { id: id }

        assert_equal 0, Bundle.where(_id: id).count, 'Should have deleted bundle'
        assert_equal orig_bundle_count - 1, Bundle.count, 'Should have deleted Bundle'
        assert orig_measure_count > Measure.count, 'Should have removed measures in the bundle'
        assert orig_patient_count > Patient.count, 'Should have removed patients in the bundle'
        assert orig_results_count > CQM::IndividualResult.count, 'Should have removed individual results in the bundle'
        assert orig_vendor_patient_count > CQM::VendorPatient.count, 'Should have vendor patients for the bundle'
      end
    end

    test 'should not allow non admins to remove bundle' do
      for_each_logged_in_user([USER, OWNER, VENDOR]) do
        id = Bundle.default._id
        delete :destroy, params: { id: id }
        assert_response 401
      end
    end

    test 'should be able to deprecate bundle' do
      patient = FactoryBot.create(:vendor_test_patient,
                                  bundleId: @static_bundle._id, correlation_id: @vendor.id)
      for_each_logged_in_user([ADMIN]) do
        orig_bundle_count = Bundle.available.count
        orig_measure_count = Measure.count
        orig_patient_count = Patient.count
        orig_results_count = CQM::IndividualResult.count
        orig_vendor_patient_calculation = patient.calculation_results.size
        id = @static_bundle.id
        post :deprecate, params: { id: id }

        patient.reload
        assert_not_equal orig_vendor_patient_calculation, patient.calculation_results.size
        assert_equal 0, Bundle.available.where(_id: id).count, 'Should have deprecated bundle'
        assert_equal orig_bundle_count - 1, Bundle.available.count, 'Should have deprecated Bundle'
        assert orig_measure_count == Measure.count, 'Should not have removed measures in the bundle'
        assert orig_patient_count == Patient.count, 'Should not have removed patients in the bundle'
        assert orig_results_count > CQM::IndividualResult.count, 'Should have removed individual results in the bundle'
      end
    end

    test 'should not allow non admins to deprecate bundle' do
      for_each_logged_in_user([USER, OWNER, VENDOR]) do
        id = Bundle.default._id
        delete :deprecate, params: { id: id }
        assert_response 401
      end
    end
  end
end
