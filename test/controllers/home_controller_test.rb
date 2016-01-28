require 'test_helper'
class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should get index without logged in user' do
    get :index
    assert_response :redirect
    assert_redirected_to controller: 'devise/sessions', action: 'new'
  end

  test 'should get index with logged in user' do
    collection_fixtures('users')
    sign_in User.first

    get :index
    assert_response :redirect
    assert_redirected_to controller: 'vendors', action: 'index'
  end
end
