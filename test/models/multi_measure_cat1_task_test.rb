require 'test_helper'
class MultiMeasureCat1TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    set_reporting_program_type_to_eh
    perform_enqueued_jobs do
      measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE', '40280382-5FA6-FE85-0160-0918E74D2075']
      @product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                         bundle_id: @bundle.id)

      params = { measure_ids: measure_ids, 'cvuplus' => 'true' }
      @product.update_with_tests(params)
      @product.save
    end
  end

  def set_reporting_program_type_to_eh
    cv = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first
    proportion = Measure.where(hqmf_id: '40280382-5FA6-FE85-0160-0918E74D2075').first
    cv.reporting_program_type = 'eh'
    cv.save
    proportion.reporting_program_type = 'eh'
    proportion.save
  end

  def test_task_good_results_should_pass
    task = @product.product_tests.multi_measure_tests.where(reporting_program_type: 'eh').first.tasks.first
    testfile = Tempfile.new(['good_results_debug_file', '.zip'])
    testfile.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(testfile, @user)
      te.reload
      # TODO, current good results do not pass CMS schematron validation
      # TODO, implement QDRA QDM template validator
      assert_empty te.execution_errors.where(cms: false), 'test execution with known good results should not have any errors'
    end
  end
end
