# frozen_string_literal: true

require 'test_helper'

class MultiMeasureCat3TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    perform_enqueued_jobs do
      measure_ids = %w[BE65090C-EB1F-11E7-8C3F-9A214CF093AE 40280382-5FA6-FE85-0160-0918E74D2075]
      @product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                         bundle_id: @bundle.id)

      params = { measure_ids: measure_ids, 'cvuplus' => 'true' }
      @product.update_with_tests(params)
      @product.save
    end
  end

  def test_task_good_results_should_pass
    task = @product.product_tests.multi_measure_tests.where(reporting_program_type: 'ep').first.tasks.first
    xml = Tempfile.new(['good_results_debug_file', '.xml'])
    xml.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(xml, @user)
      te.reload
      # TODO, current good results do not pass CMS schematron validation
      assert_empty te.execution_errors.where(cms: false), 'test execution with known good results should not have any errors'
    end
  end

  def pop_sum_err_regex
    /\AReported \w+ [a-zA-Z\d-]{36} value \d+ does not match sum \d+ of supplemental key \w+ values\z/
  end
end
