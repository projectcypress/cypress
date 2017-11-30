require 'test_helper'
class QrdaCat1ValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    collection_fixtures('bundles', 'measures')
    @bundle = Bundle.find('4fdb62e01d41c820f6000001')
    @measures = Measure.in(hqmf_id: ['8A4D92B2-397A-48D2-0139-7CC6B5B8011E'])
    @validator_with_c3 = QrdaCat1Validator.new(@bundle, false, true, @measures)
    @validator_without_c3 = QrdaCat1Validator.new(@bundle, false, false, @measures)
    @task = C1Task.new
  end

  def test_validate_good_file
    file = File.new(Rails.root.join('test', 'fixtures', 'product_tests', 'ep_qrda_test_good', '0_Dental_Peds_A.xml')).read
    @validator_with_c3.validate(file, task: @task)
    assert_empty @validator_with_c3.errors

    @validator_without_c3.validate(file, task: @task)
    assert_empty @validator_without_c3.errors
  end

  def test_validate_too_much_data_error
    file = File.new(Rails.root.join('test', 'fixtures', 'product_tests', 'ep_qrda_test_too_much_data', '0_Dental_Peds_A.xml')).read
    @validator_with_c3.validate(file, task: @task)

    errors = @validator_with_c3.errors
    assert_not_empty errors
    errors.each do |e|
      assert_equal :error, e.msg_type, 'All validation messages should be errors when c3 is included'
    end

    @validator_without_c3.validate(file, task: @task)
    errors_no_c3 = @validator_without_c3.errors
    assert_not_empty errors_no_c3
    errors_no_c3.each do |e|
      assert_equal :warning, e.msg_type, 'All validation messages should be warnings when c3 is not included'
    end

    assert_equal errors.length, errors_no_c3.length, 'Should have same number of errors regardless of c3'
  end

  def test_bad_schema
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_1', 'bad_schema.xml')).read
    @validator_with_c3.validate(file, task: @task)

    errors = @validator_with_c3.errors
    assert_not_empty errors
    errors.each do |e|
      assert_equal :error, e.msg_type, 'All validation messages should be errors for a bad schema'
    end
  end
end
