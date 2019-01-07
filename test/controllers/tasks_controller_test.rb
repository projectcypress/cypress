require 'test_helper'
require 'api_test'

class TasksControllerTest < ActionController::TestCase
  include ApiTest

  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:atl_user)
    FactoryBot.create(:user_user)
    vendor_user = FactoryBot.create(:vendor_user)
    FactoryBot.create(:other_user)
    @test = FactoryBot.create(:product_test_static_result)
    @product = @test.product
    @task = @test.tasks.first
    add_user_to_vendor(vendor_user, @product.vendor)
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to index for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, params: { product_test_id: @test.id }
      assert_response 401, "#{@user.email} should have not access "
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to show for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, params: { id: @task.id }
      assert_response 401, "#{@user.email} should not  have access "
    end
  end

  # # # # # #
  #   API   #
  # # # # # #

  # json

  test 'should get index with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, params: { :format => :json, :product_test_id => @test.id }
      assert_response 200, 'response should be OK on index'
      response_body = JSON.parse(response.body)
      assert_equal @test.tasks.count, response_body.count
      response_body.each do |response_task|
        assert_has_task_attributes response_task
      end
    end
  end

  test 'should get show with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :product_test_id => @test.id, :id => @task.id }
      assert_response 200, 'response should be OK on show'
      assert_has_task_attributes JSON.parse(response.body)
    end
  end

  test 'should get show with json request without product_test_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :id => @task.id }
      assert_response 200, 'response should be OK on show'
      assert_has_task_attributes JSON.parse(response.body)
    end
  end

  # xml

  test 'should get index with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :params => { :format => :xml, :product_test_id => @test.id }
      assert_response 200, 'response should be OK on index'
    end
  end

  test 'should get show with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :xml, :product_test_id => @test.id, :id => @task.id }
      assert_response 200, 'response should be OK on show'
    end
  end

  test 'should get show with xml request without product_test_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :xml, :id => @task.id }
      assert_response 200, 'response should be OK on show'
    end
  end

  # unsuccessful requests

  test 'should restrict access to get index with json request' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, :params => { :format => :json, :product_test_id => @test.id }
      assert_response 401, 'response should be Unauthorized on index'
    end
  end

  test 'should not get index with json request with bad product_test_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :params => { :format => :json, :product_test_id => 'bad_id' }
      assert_response 404, 'response should be Not Found on show with bad product_test_id'
    end
  end

  test 'should restrict access to get show with json request' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, :params => { :format => :json, :product_test_id => @test.id, :id => @task.id }
      assert_response 401, 'response should be Unauthorized on show'
    end
  end

  test 'should not get show with json request with bad id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :product_test_id => @test.id, :id => 'bad_id' }
      assert_response 404, 'response should be Not Found on show with bad task_id'
    end
  end

  # # # # # # # # # #
  #   H E L P E R   #
  # # # # # # # # # #

  def assert_has_task_attributes(hash)
    assert_has_attributes(hash, %w[type links], %w[self executions])
  end
end
