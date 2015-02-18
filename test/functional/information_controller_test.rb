require 'test_helper'

class InformationControllerTest < ActionController::TestCase
  
  setup do
    collection_fixtures('bundles','_id')
  end
  
  test "feedback" do
    get :feedback 
    assert_response :success
  end

end
