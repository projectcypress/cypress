require 'test_helper'
class BundlesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'users')
    sign_in User.first
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert assigns(:bundles)
  end

  test 'should import new bundle successfully' do
    orig_count = Bundle.count

    upload = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/bundles/minimal_bundle.zip'), 'application/zip')

    post :create, file: upload

    assert_equal orig_count + 1, Bundle.count, 'Should have added 1 new Bundle'
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
    orig_count = Bundle.count
    id = Bundle.first._id

    delete :destroy, id: id

    assert_equal 0, Bundle.where(_id: id).count, 'Should have deleted bundle'
    assert_equal orig_count - 1, Bundle.count, 'Should have deleted Bundle'
  end
end
