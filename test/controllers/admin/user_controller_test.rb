require "test_helper"
class Admin::UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers


  def setup
    collection_fixtures "users"
    @user = User.first
  end

  test "Admin can view index " do
    for_each_logged_in_user([ADMIN]) do
      get :index
      assert_response :success
      assert assigns(:users)
    end
  end

  test "Non Admin cannot view index " do
    for_each_logged_in_user([OWNER,ATL,VENDOR]) do
      get :index
      assert_response 401
    end
  end

  test "Admin can view edit screen " do
    for_each_logged_in_user([ADMIN]) do
      get :edit , id: @user.id
      assert_response :success
      assert assigns(:user)
    end
  end

  test "Non Admin cannot view edit " do
    for_each_logged_in_user([OWNER,ATL,VENDOR]) do
      get :edit, id: @user.id
      assert_response 401
    end
  end

  test "Admin can view show " do

  end

  test "Non Admin cannot view show " do
    for_each_logged_in_user([OWNER,ATL,VENDOR]) do
      get :show, id: @user.id
      assert_response 401
    end
  end

  test "Admin can update user" do

  end

  test "Non Admin cannot update user " do
    for_each_logged_in_user([OWNER,ATL,VENDOR]) do
      post :update,  id: @user.id
      assert_response 401
    end
  end

  test "Admin can delete user" do

  end

  test "Non Admin cannot delete user " do
    for_each_logged_in_user([OWNER,ATL,VENDOR]) do
      delete id: @user.id
      assert_response 401
    end
  end

  test "Admin can send invitation " do

  end

  test "Non Admin cannot  send invitation " do

  end

  test "Admin can toggle approved status " do

  end

  test "Non Admin cannot toggle approved status " do

  end

  test "Admin can unlock a locked account " do

  end

  test "Non Admin cannot unlock a locked account" do

  end
end
