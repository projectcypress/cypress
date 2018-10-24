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

        upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'bundles', 'minimal_test_bundle.zip'), 'application/zip')
        perform_enqueued_jobs do
          post :create, params: { file: upload }
          assert_performed_jobs 2
          assert_equal orig_bundle_count + 1, Bundle.count, 'Should have added 1 new Bundle'
          assert orig_measure_count < Measure.count, 'Should have added new measures in the bundle'
          assert orig_patient_count < Patient.count, 'Should have added new patients in the bundle'
        end
      end
    end

    test 'should deny access to import for non admin users ' do
      for_each_logged_in_user([USER, OWNER, VENDOR]) do
        upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'bundles', 'minimal_test_bundle.zip'), 'application/zip')
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
      for_each_logged_in_user([ADMIN]) do
        orig_bundle_count = Bundle.count
        orig_measure_count = Measure.count
        orig_patient_count = Patient.count
        orig_results_count = QDM::IndividualResult.count
        id = @static_bundle.id

        delete :destroy, params: { id: id }

        assert_equal 0, Bundle.where(_id: id).count, 'Should have deleted bundle'
        assert_equal orig_bundle_count - 1, Bundle.count, 'Should have deleted Bundle'
        assert orig_measure_count > Measure.count, 'Should have removed measures in the bundle'
        assert orig_patient_count > Patient.count, 'Should have removed patients in the bundle'
        assert orig_results_count > QDM::IndividualResult.count, 'Should have removed individual results in the bundle'
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
      for_each_logged_in_user([ADMIN]) do
        orig_bundle_count = Bundle.available.count
        orig_measure_count = Measure.count
        orig_patient_count = Patient.count
        orig_results_count = QDM::IndividualResult.count
        id = @static_bundle.id

        post :deprecate, params: { id: id }

        assert_equal 0, Bundle.available.where(_id: id).count, 'Should have deprecated bundle'
        assert_equal orig_bundle_count - 1, Bundle.available.count, 'Should have deprecated Bundle'
        assert orig_measure_count == Measure.count, 'Should not have removed measures in the bundle'
        assert orig_patient_count == Patient.count, 'Should not have removed patients in the bundle'
        assert orig_results_count > QDM::IndividualResult.count, 'Should have removed individual results in the bundle'
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
