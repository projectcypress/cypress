require 'test_helper'
class Admin::BundlesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper

  setup do
    collection_fixtures('bundles', 'measures', 'records', 'users', 'roles')
    FileUtils.rm_rf(Cypress::AppConfig['bundle_file_path'])
  end

  teardown do
    load_library_functions
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

  test 'admin user should import new bundle successfully' do
    for_each_logged_in_user([ADMIN]) do
      orig_bundle_count = Bundle.count
      orig_measure_count = Measure.count
      orig_record_count = Record.count

      upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/bundles/minimal_bundle.zip'), 'application/zip')
      perform_enqueued_jobs do
        post :create, file: upload
        assert_performed_jobs 2
        assert_equal orig_bundle_count + 1, Bundle.count, 'Should have added 1 new Bundle'
        assert orig_measure_count < Measure.count, 'Should have added new measures in the bundle'
        assert orig_record_count < Record.count, 'Should have added new records in the bundle'
      end
    end
  end

  test 'should deny access to import for non admin users ' do
    for_each_logged_in_user([USER, OWNER, VENDOR]) do
      upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/bundles/minimal_bundle.zip'), 'application/zip')
      post :create, file: upload
      assert_response 401
    end
  end

  test 'should not import file that is not a bundle' do
    for_each_logged_in_user([ADMIN]) do
      orig_count = Bundle.count

      upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/artifacts/qrda.zip'), 'application/zip')
      assert_equal 0, BundleUploadJob.trackers.count, 'should be 0 trackers in db'
      perform_enqueued_jobs do
        post :create, file: upload
        assert_performed_jobs 1
        assert_equal 1, BundleUploadJob.trackers.count, 'should be 1 tracker in db'
        assert_equal :failed, BundleUploadJob.trackers.first.status, 'Status of tracker should be failed '
        assert_equal orig_count, Bundle.count, 'Should not have added new Bundle'
      end
    end
  end

  test 'should be able to change default bundle' do
    yml_text = File.read("#{Rails.root}/config/cypress.yml")
    for_each_logged_in_user([ADMIN]) do
      flunk 'Should have at least 2 test bundles' if Bundle.count < 2

      active_bundle = Bundle.default
      inactive_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample

      post :set_default, id: inactive_bundle._id

      active_bundle.reload
      inactive_bundle.reload

      assert inactive_bundle.active, 'new default bundle should be active'
      assert !active_bundle.active, 'old default bundle should no longer be active'
    end
    # revert change to cypress.yml
    File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts yml_text }
  end

  test 'should not allow a non admin to change default bundle' do
    for_each_logged_in_user([USER, OWNER, VENDOR]) do
      flunk 'Should have at least 2 test bundles' if Bundle.count < 2
      inactive_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample

      post :set_default, id: inactive_bundle._id
      assert_response 401
    end
  end

  test 'should be able to remove bundle' do
    for_each_logged_in_user([ADMIN]) do
      orig_bundle_count = Bundle.count
      orig_measure_count = Measure.count
      orig_record_count = Record.count
      id = '4fdb62e01d41c820f6000001'

      delete :destroy, id: id

      assert_equal 0, Bundle.where(_id: id).count, 'Should have deleted bundle'
      assert_equal orig_bundle_count - 1, Bundle.count, 'Should have deleted Bundle'
      assert orig_measure_count > Measure.count, 'Should have removed measures in the bundle'
      assert orig_record_count > Record.count, 'Should have removed records in the bundle'
    end
  end

  test 'should not allow non admins to remove bundle' do
    for_each_logged_in_user([USER, OWNER, VENDOR]) do
      id = Bundle.default._id
      delete :destroy, id: id
      assert_response 401
    end
  end
end
