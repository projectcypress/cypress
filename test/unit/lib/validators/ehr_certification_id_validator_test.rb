# frozen_string_literal: true

require 'test_helper'
class EhrCertificationIdValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = Validators::EhrCertificationIdValidator.new
    @options = { task: FactoryBot.create(:task) }
  end

  def test_document_with_properly_formatted_cms_id
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 0, @validator.errors.count, "Expected 0 error, got #{@validator.errors}"
  end

  def test_document_with_invalid_cms_id
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'good_cat1_single_encounter.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
    execution_error = @validator.errors.first
    assert_equal :warning, execution_error.msg_type, "Expected error to be of type :warning for wrong pattern"
  end

  def test_document_with_cms_id_wrong_length
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_unit_missing.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
    execution_error = @validator.errors.first
    assert_equal :error, execution_error.msg_type, "Expected error to be of type :error for wrong length"
  end
end
