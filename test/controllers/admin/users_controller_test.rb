require 'test_helper'
module Admin
  class UsersControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    def setup
      FactoryBot.create(:admin_user)
      FactoryBot.create(:user_user)
      FactoryBot.create(:vendor_user)
      FactoryBot.create(:other_user)
      @user = FactoryBot.create(:atl_user)
      @vendor = FactoryBot.create(:vendor)
    end

    test 'Admin can view index ' do
      for_each_logged_in_user([ADMIN]) do
        get :index
        assert_redirected_to %r{/admin#user_management}
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
        get :edit, params: { id: @user.id }
        assert_response :success
        assert assigns(:user)
      end
    end

    test 'Non Admin cannot view edit ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :edit, params: { id: @user.id }
        assert_response 401
      end
    end

    test 'Admin can update user' do
      Settings.current.update(default_role: '')
      u = User.create(email: 'admin_test@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')

      for_each_logged_in_user([ADMIN]) do
        assert_not u.user_role?(:user)
        assert_not u.user_role?(:owner, @vendor)
        patch :update, params: { :id => u.id, :role => :user, :assignments => { '0' => { :role => :owner, :vendor_id => @vendor.id } } }
        assert_response 302
        u.reload
        assert u.user_role?(:user)
        assert u.user_role?(:owner, @vendor)
      end
    end

    test 'Non Admin cannot update user ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        post :update, :params => { :id => @user.id }
        assert_response 401
      end
    end

    test 'Admin can delete user' do
      u = User.create(:email => 'admin_test@test.com', :password => 'TestTest!', :password_confirmation => 'TestTest!', :terms_and_conditions => '1')
      for_each_logged_in_user([ADMIN]) do
        delete :destroy, :params => { :id => u.id }
        assert_response 302
        assert_equal 0, User.where('_id' => u.id).count
      end
    end

    test 'Non Admin cannot delete user ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        delete :destroy, :params => { :id => @user.id }
        assert_response 401
      end
    end

    test 'Admin can send invitation ' do
      for_each_logged_in_user([ADMIN]) do
        get :send_invitation, :params => { :id => @user.id }
        assert_response 302
      end
    end

    test 'Non Admin cannot  send invitation ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :send_invitation, :params => { :id => @user.id }
        assert_response 401
      end
    end

    test 'Admin can toggle approved status ' do
      u = User.create(:email => 'admin_test@test.com', :password => 'TestTest!', :password_confirmation => 'TestTest!', :terms_and_conditions => '1')
      approved = u.approved
      for_each_logged_in_user([ADMIN]) do
        get :toggle_approved, :params => { :id => u.id }
        assert_response 302
        assert_equal !approved, User.find(u.id).approved
        get :toggle_approved, :params => { :id => u.id }
        assert_response 302
        assert_equal approved, User.find(u.id).approved
      end
    end

    test 'Non Admin cannot toggle approved status ' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :toggle_approved, :params => { :id => @user.id }
        assert_response 401
      end
    end

    test 'Admin can unlock a locked account ' do
      u = User.create(:email => 'admin_test@test.com', :password => 'TestTest!', :password_confirmation => 'TestTest!', :terms_and_conditions => '1', :locked_at => Time.now.in_time_zone)
      for_each_logged_in_user([ADMIN]) do
        assert_not u.locked_at.nil?
        get :unlock, :params => { :id => u.id }
        assert_response 302
        assert User.find(u.id).locked_at.nil?
      end
    end

    test 'Non Admin cannot unlock a locked account' do
      for_each_logged_in_user([OWNER, ATL, VENDOR]) do
        get :unlock, :params => { :id => @user.id }
        assert_response 401
      end
    end
  end
end
