require 'test_helper'
class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should get index without logged in user' do
    get :index
    assert_response :redirect
    assert_redirected_to controller: 'sessions', action: 'new'
  end

  test 'should get index with logged in user' do
    FactoryGirl.create(:atl_user)
    sign_in User.find('4def93dd4f85cf8968000001')

    get :index
    assert_response :redirect
    assert_redirected_to controller: 'vendors', action: 'index'
  end
end
