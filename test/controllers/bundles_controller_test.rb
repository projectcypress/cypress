require 'test_helper'
class BundlesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'measures', 'records', 'users')
    enable_page
    sign_in User.first
  end

  def disable_page
    APP_CONFIG['disable_bundle_page'] = true
  end

  def enable_page
    APP_CONFIG['disable_bundle_page'] = false
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert assigns(:bundles)
  end

  test 'should import new bundle successfully' do
    orig_bundle_count = Bundle.count
    orig_measure_count = Measure.count
    orig_record_count = Record.count

    upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/bundles/minimal_bundle.zip'), 'application/zip')

    post :create, file: upload

    assert_equal orig_bundle_count + 1, Bundle.count, 'Should have added 1 new Bundle'
    assert orig_measure_count < Measure.count, 'Should have added new measures in the bundle'
    assert orig_record_count < Record.count, 'Should have added new records in the bundle'
  end

  test 'should not import file that is not a bundle' do
    orig_count = Bundle.count

    upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/artifacts/qrda.zip'), 'application/zip')

    post :create, file: upload

    assert_not_nil flash[:alert], 'Should have an error message'
    assert_equal orig_count, Bundle.count, 'Should not have added new Bundle'
  end

  test 'should be able to change default bundle' do
    flunk 'Should have at least 2 test bundles' if Bundle.count < 2

    active_bundle = Bundle.where('active' => true).first # there should only be one
    inactive_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample

    post :set_default, id: inactive_bundle._id

    active_bundle.reload
    inactive_bundle.reload

    assert inactive_bundle.active, 'new default bundle should be active'
    assert !active_bundle.active, 'old default bundle should no longer be active'
  end

  test 'should be able to remove bundle' do
    orig_bundle_count = Bundle.count
    orig_measure_count = Measure.count
    orig_record_count = Record.count
    id = Bundle.first._id

    delete :destroy, id: id

    assert_equal 0, Bundle.where(_id: id).count, 'Should have deleted bundle'
    assert_equal orig_bundle_count - 1, Bundle.count, 'Should have deleted Bundle'
    assert orig_measure_count > Measure.count, 'Should have removed measures in the bundle'
    assert orig_record_count > Record.count, 'Should have removed records in the bundle'
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

    active_bundle = Bundle.where('active' => true).first # there should only be one
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
    id = Bundle.first._id

    delete :destroy, id: id

    assert_equal 1, Bundle.where(_id: id).count, 'Should not have deleted bundle'
    assert_equal orig_count, Bundle.count, 'Should not have deleted Bundle'
  end
end
