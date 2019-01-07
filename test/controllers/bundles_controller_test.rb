require 'test_helper'
class BundlesControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:user_user)
    FactoryBot.create(:vendor_user)
    FactoryBot.create(:other_user)
    @user = FactoryBot.create(:atl_user)
    FactoryBot.create(:static_bundle)
    FileUtils.rm_rf(APP_CONSTANTS['bundle_file_path'])
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # json

  test 'should get index with json request' do
    for_each_logged_in_user([ADMIN]) do
      get :index, :format => :json
      assert_response 200, 'response should be OK on bundle index'
      assert_equal Bundle.all.count, JSON.parse(response.body).count, 'response body should have all bundles'
    end
  end

  test 'should get show with json request' do
    for_each_logged_in_user([ADMIN]) do
      get :show, :params => { :format => :json, :id => Bundle.default.id }
      assert_response 200, 'response should be OK on bundle show'
      assert_not_empty JSON.parse(response.body), 'response body should contain bundle'
    end
  end

  # xml

  test 'should get index with xml request' do
    for_each_logged_in_user([ADMIN]) do
      get :index, :format => :xml
      assert_response 200, 'response should be OK on bundle index'
    end
  end

  test 'should get show with xml request' do
    for_each_logged_in_user([ADMIN]) do
      get :show, :params => { :format => :xml, :id => Bundle.default.id }
      assert_response 200, 'response should be OK on bundle show'
    end
  end

  # bad requests

  test 'should not get show with json request with bad id' do
    for_each_logged_in_user([ADMIN]) do
      get :show, :params => { :format => :json, :id => 'bad_id' }
      assert_response 404, 'response should be Not Found if bad id given'
      assert_equal 'Not Found', response.message
    end
  end
end
