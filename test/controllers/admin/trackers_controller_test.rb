require 'test_helper'

module Admin
  class TrackersControllerTest < ActionController::TestCase
    setup do
      FactoryBot.create(:admin_user)
      @controller = Admin::TrackersController.new
    end

    test 'should successfully destroy tracker' do
      tracker = Tracker.find_or_create_by(job_id: BSON::ObjectId.new)
      for_each_logged_in_user([ADMIN]) do
        delete :destroy, params: { id: tracker.id }
      end
    end
  end
end
