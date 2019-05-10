require 'test_helper'
class CMSProgramTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
  end

  def setup_eh
    modify_reporting_program_type('eh')
    perform_enqueued_jobs do
      measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE', '40280382-5FA6-FE85-0160-0918E74D2075']
      @product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                         bundle_id: @bundle.id)

      params = { measure_ids: measure_ids, 'cvuplus' => 'true' }
      @product.update_with_tests(params)
      @product.save
    end
  end

  def setup_ep
    modify_reporting_program_type('ep')
    perform_enqueued_jobs do
      measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE', '40280382-5FA6-FE85-0160-0918E74D2075']
      @product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                         bundle_id: @bundle.id)

      params = { measure_ids: measure_ids, 'cvuplus' => 'true' }
      @product.update_with_tests(params)
      @product.save
    end
  end

  def modify_reporting_program_type(program_type)
    cv = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first
    proportion = Measure.where(hqmf_id: '40280382-5FA6-FE85-0160-0918E74D2075').first
    cv.reporting_program_type = program_type
    cv.save
    proportion.reporting_program_type = program_type
    proportion.save
  end

  def test_ep_task_with_errors
    setup_ep
    task = @product.product_tests.cms_program_tests.where(cms_program: 'MIPS_VIRTUALGROUP').first.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 24, te.execution_errors.size
    end
  end

  def test_eh_task_with_errors
    setup_eh
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HQR_PI').first
    pc = pt.program_criteria.where(criterium_key: 'CCN').first
    pc.entered_value = '563358'
    pt.save
    task = pt.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 14, te.execution_errors.size
    end
  end
end
