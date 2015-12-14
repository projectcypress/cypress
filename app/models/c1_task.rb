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
    c3_validation = false
    @validators = [QrdaCat1Validator.new(product_test.bundle, c3_validation, product_test.measures),
                   SmokingGunValidator.new(product_test.measures, product_test.records, product_test.id)]

    @validators
  end

  def execute(file)
    if product_test.contains_c3_task?
      product_test.tasks.each do |task|
        if task._type == 'C3Task'
          task.cat1
          task.execute(file)
        end
      end
    end
    te = test_executions.create(expected_results: expected_results)
    te.artifact = Artifact.new(file: file)
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end

  def records
    patient_ids = product_test.results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
    product_test.records.in('_id' => patient_ids)
  end
end
