require 'test_helper'

class C3ChecklistTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    product = FactoryGirl.create(:product_static_bundle)
    product.c3_test = true
    product.save
    @checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    @checklist_test.save!
    @checklist_test.create_checked_criteria
    simplify_criteria(@checklist_test)
    C3ChecklistTask.new(product_test: @checklist_test).save!
  end

  def test_validators_exist
    task = @checklist_test.tasks[0]
    validators = [QrdaCat1Validator]
    assert arrays_equivalent(validators, task.validators.collect(&:class))
  end

  # TODO: add tests for good and bad test executions
end
