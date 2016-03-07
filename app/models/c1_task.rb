require 'validators/smoking_gun_validator'
require 'validators/qrda_cat1_validator'

class C1Task < Task
  include Mongoid::Attributes::Dynamic
  include ::Validators

  # C1 = Record and Export
  #  - Record all the data needed to calculate CQMs
  #  - Export data as Cat 1
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = [CalculatingSmokingGunValidator.new(product_test.measures, product_test.records, product_test.id),
                   QrdaCat1Validator.new(product_test.bundle, false, product_test.product.c3_test, product_test.measures)]
    @validators
  end

  def execute(file)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = product_test.tasks.c3_cat1_task.execute(file, te.id).id if product_test.product.c3_test
    te.save
    te
  end

  def records
    patient_ids = product_test.results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
    product_test.records.in('_id' => patient_ids)
  end

  # returns combined status including c3_cat1 task
  def status_with_sibling
    return status unless product_test.tasks.c3_cat1_task
    return status if status == product_test.tasks.c3_cat1_task.status
    'failing'
  end
end
