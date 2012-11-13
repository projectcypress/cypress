require 'test_helper'

class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    collection_fixtures('test_executions', '_id')
    collection_fixtures('measures')
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('records', '_id')
    
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end
  
  test "new" do
    pending
  end

  test "show" do
    pending
  end

  test "create" do
    pending
  end

  test "destroy" do
    pending
  end

  test "download" do
    pending
  end
end