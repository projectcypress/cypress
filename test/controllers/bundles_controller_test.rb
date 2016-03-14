require 'test_helper'
class BundlesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper
  setup do
    collection_fixtures('bundles', 'measures', 'records', 'users', 'roles')
    enable_page
    FileUtils.rm_rf(APP_CONFIG.bundle_file_path)
  end

  def disable_page
    APP_CONFIG['disable_bundle_page'] = true
  end

  def enable_page
    APP_CONFIG['disable_bundle_page'] = false
  end

  test 'should get index' do
    for_each_logged_in_user([ADMIN]) do
      get :index
      assert_response :success
      assert assigns(:bundles)
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
        assert_performed_jobs 1
        assert_equal orig_bundle_count + 1, Bundle.count, 'Should have added 1 new Bundle'
        assert orig_measure_count < Measure.count, 'Should have added new measures in the bundle'
        assert orig_record_count < Record.count, 'Should have added new records in the bundle'
      end
    end
  end

  test 'shoud deny access to import for non admin users ' do
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
    # assert_not_nil flash[:alert], 'Should have an error message'
  end

  test 'should be able to change default bundle' do
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

  test 'should not import new bundle when page disabled' do
    disable_page
    orig_count = Bundle.count

    upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/bundles/minimal_bundle.zip'), 'application/zip')

    post :create, file: upload

    assert_equal orig_count, Bundle.count, 'Should not have added new Bundle'
  end

  test 'should not be able to change default bundle when page disabled' do
    disable_page
    flunk 'Should have at least 2 test bundles' if Bundle.count < 2

    active_bundle = Bundle.default
    inactive_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample

    post :set_default, id: inactive_bundle._id

    active_bundle.reload
    inactive_bundle.reload

    assert !inactive_bundle.active, 'non-default bundle should still not be active'
    assert active_bundle.active, 'old default bundle should still be active'
  end

  test 'should not be able to remove bundle when page disabled' do
    disable_page
    orig_count = Bundle.count
    id = Bundle.all.sample._id

    delete :destroy, id: id

    assert_equal 1, Bundle.where(_id: id).count, 'Should not have deleted bundle'
    assert_equal orig_count, Bundle.count, 'Should not have deleted Bundle'
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # json

  test 'should get index with json request' do
    get :index, :format => :json
    assert_response 200, 'response should be OK on bundle index'
    assert_equal Bundle.all.count, JSON.parse(response.body).count, 'response body should have all bundles'
  end

  test 'should get show with json request' do
    get :show, :format => :json, :id => Bundle.first.id
    assert_response 200, 'response should be OK on bundle show'
    assert_not_empty JSON.parse(response.body), 'response body should contain bundle'
  end

  # xml

  test 'should get index with xml request' do
    get :index, :format => :xml
    assert_response 200, 'response should be OK on bundle index'
  end

  test 'should get show with xml request' do
    get :show, :format => :xml, :id => Bundle.first.id
    assert_response 200, 'response should be OK on bundle show'
  end

  # bad requests

  test 'should not get show with json request with bad id' do
    get :show, :format => :json, :id => 'bad_id'
    assert_response 404, 'response should be Not Found if bad id given'
    assert_equal '', response.body, 'response body should be empty for Not Found'
  end
end
