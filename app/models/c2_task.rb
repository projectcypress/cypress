# frozen_string_literal: true

require 'validators/qrda_cat3_validator'

class C2Task < Task
  # C2 = Import and Calculate
  #  - Ability to Import Cat 1
  #  - Calculate every CQM
  #  - (implied) ability to export cat 3 (in order to be able to prove it)
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = if product_test.c2_test
                    [::Validators::QrdaCat3Validator.new(product_test.expected_results,
                                                         false,
                                                         product_test.c3_test,
                                                         true,
                                                         product_test.bundle),
                     ::Validators::ExpectedResultsValidator.new(product_test.expected_results, product_test.bundle.randomization)]
                  else
                    # A C2 task is created whenever C3 is selected.  If C2 isn't also selected, this task doesn't perform any validations
                    []
                  end
    @validators
  end

  def execute(file, user)
    te = test_executions.new(expected_results:, artifact: Artifact.new(file:), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = product_test.tasks.c3_cat3_task.execute(file, user, te.id).id if product_test.c3_cat3_task?
    te.save
    te
  end

  def good_results
    # Set the Submission Program to MIPS_INDIV if there is a C3 test and the test is for an ep measure.
    cat3_submission_program = if product_test&.product&.c3_test && product_test&.ep_measures?
                                product_test&.submission_program
                              else
                                false
                              end
    options = { provider: product_test.patients.first.providers.first, submission_program: cat3_submission_program,
                start_time: start_date, end_time: end_date, ry2025_submission: product_test.bundle.major_version == '2024' }
    Qrda3.new(product_test.expected_results_with_all_supplemental_codes, product_test.measures, options).render
  end

  def last_updated_with_sibling
    sibling = product_test.tasks.c3_cat3_task
    return updated_at unless sibling

    [updated_at, sibling.updated_at].max
  end

  # returns combined status including c3_cat3 task
  def status_with_sibling
    sibling = product_test.tasks.c3_cat3_task
    return status unless sibling
    return status if status == sibling.status
    return 'errored' if errored? || sibling.errored?
    return 'incomplete' if incomplete? || sibling.incomplete?
    return 'pending' if pending? || sibling.pending?

    'failing'
  end
end
