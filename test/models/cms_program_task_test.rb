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
      measure_ids = %w[BE65090C-EB1F-11E7-8C3F-9A214CF093AE 40280382-5FA6-FE85-0160-0918E74D2075]
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
      measure_ids = %w[BE65090C-EB1F-11E7-8C3F-9A214CF093AE 40280382-5FA6-FE85-0160-0918E74D2075]
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
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'cms_test_qrda_cat3.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 54, te.execution_errors.size
      assert_equal 2, te.execution_errors.where(validator: 'Validators::MeasurePeriodValidator').size
      assert_equal 1, te.execution_errors.where(validator: 'Validators::ProgramValidator').size
      assert_equal 45, te.execution_errors.where(validator: 'Validators::CMSQRDA3SchematronValidator').size
      assert_equal 4, te.execution_errors.where(validator: 'Validators::Cat3PopulationValidator').size # One for each demographic
      assert_equal 1, te.execution_errors.where(validator: 'Validators::ProgramCriteriaValidator').size
      assert_equal 1, te.execution_errors.where(validator: 'Validators::EHRCertificationIdValidator').size
    end
  end

  def test_ep_task_returns_appropriate_error_for_incorrect_measure_id
    setup_ep
    task = @product.product_tests.cms_program_tests.where(cms_program: 'MIPS_VIRTUALGROUP').first.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good_invalid_id.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal :failed, te.state
      assert_equal 1, te.execution_errors.where(message: 'Invalid HQMF ID Found: 40280382-5FA6-FE85-0160-0918E74D2076').size
    end
  end

  def test_ep_task_with_errors_for_cv_measure
    setup_ep
    task = @product.product_tests.cms_program_tests.where(cms_program: 'MIPS_VIRTUALGROUP').first.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'cms_test_qrda_cat3_cv.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 14, te.execution_errors.size
      assert_equal 1, te.execution_errors.where(validator: 'Validators::ProgramValidator').size
      assert_equal 12, te.execution_errors.where(validator: 'Validators::Cat3PopulationValidator').size
      assert_equal 1, te.execution_errors.where(validator: 'Validators::ProgramCriteriaValidator').size
    end
  end

  def test_pcf_task_with_errors_for_cv_measure
    setup_ep
    task = @product.product_tests.cms_program_tests.where(cms_program: 'PCF').first.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'cms_test_qrda_cat3_cv.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 17, te.execution_errors.size
      assert_equal 1, te.execution_errors.where(validator: 'Validators::ProgramValidator').size
      assert_equal 12, te.execution_errors.where(validator: 'Validators::Cat3PopulationValidator').size
      assert_equal 4, te.execution_errors.where(validator: 'Validators::ProgramCriteriaValidator').size
    end
  end

  def test_eh_task_with_errors
    setup_eh
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HQR_PI').first
    pc = pt.program_criteria.where(criterion_key: 'CCN').first
    pc.entered_value = '563358'
    pt.save
    task = pt.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 12, te.execution_errors.size
      assert_equal 1, te.execution_errors.where(validator: 'Validators::MeasurePeriodValidator').size
      assert_equal 6, te.execution_errors.where(validator: 'Validators::ProgramCriteriaValidator').size
      assert_equal 5, te.execution_errors.where(validator: 'Validators::CMSQRDA1HQRSchematronValidator').size
    end
  end

  def test_eh_task_with_missing_measure_id
    setup_eh
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HQR_PI').first
    task = pt.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_ecqm.zip'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 1, te.execution_errors.where(message: 'Document does not state it is reporting measure CMS32v7').size
    end
  end

  def test_qrda1_task_with_errors
    setup_eh
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HL7_Cat_I').first
    task = pt.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_bad_schema.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 1, te.execution_errors.size
      # This is a schematron error
      assert_equal 1, te.execution_errors.where(validator: 'CqmValidators::Cat1R52').size
    end
  end

  def test_telehealth_calcuations
    setup_eh
    measure = Measure.find_by(cms_id: 'CMS32v7')
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HL7_Cat_I').first
    task = pt.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good_telehealth.xml'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      ir = CQM::IndividualResult.where(measure_id: measure.id, correlation_id: te.id, population_set_key: 'PopulationCriteria1')
      assert_equal ir.first.patient.bundle.id, task.bundle.id
      assert_equal 1, ir.first['IPP']
    end

    APP_CONSTANTS['telehealth_ineligible_measures'] = pt.measure_ids
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      ir = CQM::IndividualResult.where(measure_id: measure.id, correlation_id: te.id, population_set_key: 'PopulationCriteria1')
      assert_equal 0, ir.size
      assert_equal 1, te.execution_errors.where(message: 'Telehealth encounter 720 with modifier GQ not used in calculation for eCQMs (CMS32v7, CMS134v6) that are not eligible for telehealth.').size
    end
  end

  def test_calculation_status
    setup_eh
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HL7_Cat_I').first
    task = pt.tasks.first
    execution = task.test_executions.build
    Tracker.create(options: { test_execution_id: execution.id })
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good_telehealth.xml'))
    options = { file_name: 'sample_patient_good_telehealth.xml', task: task, test_execution: execution }
    pcv = ProgramCriteriaValidator.new(pt)
    pcv.instance_variable_set(:@file, execution.build_document(file))
    pcv.import_patient(options, @product.product_tests.first.measure_ids)
    tej = CMSTestExecutionJob.new
    tej.calculate_patients(execution)
    assert_equal execution.tracker.log_message[0], '50% of calculations complete'
  end

  def test_eh_task_with_errors_quarter_reporting
    setup_eh
    pt = @product.product_tests.cms_program_tests.where(cms_program: 'HQR_PI').first
    pc = pt.program_criteria.where(criterion_key: 'CCN').first
    pc.entered_value = '563358'
    pt.save
    task = pt.tasks.first
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good_quarter.zip'))
    perform_enqueued_jobs do
      te = task.execute(file, @user)
      te.reload
      assert_equal 11, te.execution_errors.size
      assert_equal 6, te.execution_errors.where(validator: 'Validators::ProgramCriteriaValidator').size
      assert_equal 5, te.execution_errors.where(validator: 'Validators::CMSQRDA1HQRSchematronValidator').size
    end
  end
end
