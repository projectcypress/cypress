require 'test_helper'
module Admin
  class UsersControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    def setup
      collection_fixtures 'users', 'roles', 'vendors'
      @user = User.first
    end

    test 'Admin can view index ' do
      for_each_logged_in_user([ADMIN]) do
        get :index
        assert_response :success
        assert assigns(:users)
      end
    end

    test 'Non Admin cannot view index ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :index
        assert_response 401
      end
    end

    test 'Admin can view edit screen ' do
      for_each_logged_in_user([ADMIN]) do
        get :edit, id: @user.id
        assert_response :success
        assert assigns(:user)
      end
    end

    test 'Non Admin cannot view edit ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :edit, id: @user.id
        assert_response 401
      end
    end

    test 'Admin can update user' do
      v = Vendor.first
      u = User.create(email: 'admin_test@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
      APP_CONFIG['default_role'] = nil
      for_each_logged_in_user([ADMIN]) do
        assert !u.has_role?(:user)
        assert !u.has_role?(:owner, v)
        patch :update, :id => u.id, :role => :user, :assignments => { '0' => { :role => :owner, :vendor_id => v.id } }
        assert_response 302
        u.reload
        assert u.has_role?(:user)
        assert u.has_role?(:owner, v)
      end
    end

    test 'Non Admin cannot update user ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        post :update, id: @user.id
        assert_response 401
      end
    end

    test 'Admin can delete user' do
      u = User.create(email: 'admin_test@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
      for_each_logged_in_user([ADMIN]) do
        delete :destroy, id: u.id
        assert_response 302
        assert_equal 0, User.where('_id' => u.id).count
      end
    end

    test 'Non Admin cannot delete user ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        delete :destroy, id: @user.id
        assert_response 401
      end
    end

    test 'Admin can send invitation ' do
      for_each_logged_in_user([ADMIN]) do
        get :send_invitation, id: @user.id
        assert_response 302
      end
    end

    test 'Non Admin cannot  send invitation ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :send_invitation, id: @user.id
        assert_response 401
      end
    end

    test 'Admin can toggle approved status ' do
      u = User.create(email: 'admin_test@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
      approved = u.approved
      for_each_logged_in_user([ADMIN]) do
        get :toggle_approved, id: u.id
        assert_response 302
        assert_equal !approved, User.find(u.id).approved
        get :toggle_approved, id: u.id
        assert_response 302
        assert_equal approved, User.find(u.id).approved
      end
    end

    test 'Non Admin cannot toggle approved status ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :toggle_approved, id: @user.id
        assert_response 401
      end
    end

    test 'Admin can unlock a locked account ' do
      u = User.create(email: 'admin_test@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1', locked_at: Time.now.utc)
      approved = u.approved
      for_each_logged_in_user([ADMIN]) do
        assert !u.locked_at.nil?
        get :unlock, id: u.id
        assert_response 302
        assert User.find(u.id).locked_at.nil?
      end
    end

    test 'Non Admin cannot unlock a locked account' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :unlock, id: @user.id
        assert_response 401
      end
    end
end
end
