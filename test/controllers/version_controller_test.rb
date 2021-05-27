# frozen_string_literal: true

require 'test_helper'
class VersionControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  setup do
     FactoryBot.create(:admin_user)
    @version = { 'version' => Cypress::Application::VERSION } 
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #


  test 'should get index with json request' do
    for_each_logged_in_user([ADMIN]) do
      get :index, format: :json
      assert_response 200, 'response should be OK on version index'
      assert_equal @version.to_json, JSON.parse(response.body).to_json
    end
  end

  test 'should get index with xml request' do
    for_each_logged_in_user([ADMIN]) do
      get :index, format: :xml
      assert_response 200, 'response should be OK on version index'
      assert_equal @version.to_xml(:root => 'version'), response.body
    end
  end
end
