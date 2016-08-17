require 'test_helper'
class MeasuresControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'measures', 'users')
    sign_in User.find('4def93dd4f85cf8968000001')
  end

  # json

  test 'should get index with json' do
    bundle = Bundle.default
    get :index, :format => :json, :bundle_id => bundle.id
    assert_response 200, 'response should be OK on product index'
    assert_equal bundle.measures.top_level.count, JSON.parse(response.body).count, 'response body should have all measures for bundle'
  end

  # xml

  test 'should get index with xml' do
    bundle = Bundle.default
    get :index, :format => :json, :bundle_id => bundle.id
    assert_response 200, 'response should be OK on product index'
  end

  # bad requests

  test 'should not get index with json with bad bundle id' do
    get :index, :format => :json, :bundle_id => 'bad_id'
    assert_response 404, 'response should be Not Found if bad id given'
    assert_equal 'Not Found', response.message
  end
end
