require 'test_helper'

class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    collection_fixtures('vendors', '_id')
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
    collection_fixtures('users')
    collection_fixtures('records', '_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in User.first(:conditions => {:username => 'bobbytables'})
  end
  
  test "index" do
    get :index
    #binding.pry
    assert_response :success
    assert assigns(:complete_vendors).empty?
    assert assigns(:incomplete_vendors).size == 1
  end
  
  test "create" do
    assert Record.count == 1
    post(:create, {:vendor => {:name => 'An EHR', :measure_ids => ['0004', '0055']}})
    assert_response :redirect
    assert Record.count == 2
  end
end
