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
    c3_validation = product_test.contains_c3_task?
    @validators = [QrdaCat1Validator.new(product_test.bundle, c3_validation, product_test.measures),
                   CalculatingSmokingGunValidator.new(product_test.measures, product_test.records, product_test.id)]

    @validators
  end

  def execute(file)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self)
    if product_test.contains_c3_task?
      product_test.tasks.each do |task|
        if task._type == 'C3Task'
          task.cat1
          te.sibling_execution_id = task.execute(file, te.id).id
        end
      end
    end
    te.save
    te
  end

  def records
    patient_ids = product_test.results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
    product_test.records.in('_id' => patient_ids)
  end

  # should only be used if product.c3_test is true
  def c3_status
    Rails.cache.fetch("#{cache_key}/status") do
      report_status = 'incomplete'
      recent_execution = most_recent_execution
      if recent_execution
        recent_c3_execution = TestExecution.find(recent_execution.sibling_execution_id)
        report_status = recent_c3_execution.passing? ? 'passing' : 'failing'
      end
      report_status
    end
  end
end
