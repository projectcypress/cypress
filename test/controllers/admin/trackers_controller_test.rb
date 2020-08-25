require 'test_helper'

module Admin
  class TrackersControllerTest < ActionController::TestCase
    setup do
      FactoryBot.create(:admin_user)
      @controller = Admin::TrackersController.new
      @vendor = FactoryBot.create(:vendor_with_points_of_contact)
    end

    test 'should successfully destroy tracker' do
      tracker = Tracker.find_or_create_by(job_id: BSON::ObjectId.new,
                                          job_class: 'PatientAnalysisJob',
                                          status: :failed,
                                          options: { vendor_id: @vendor.id })
      for_each_logged_in_user([ADMIN]) do
        delete :destroy, params: { id: tracker.id }
        assert_response 302
      end
      assert_equal 0, Tracker.all.size
    end
  end
end
