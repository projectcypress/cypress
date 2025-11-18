# frozen_string_literal: true

require 'test_helper'
class TinValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = Validators::TinValidator.new
    @options = { task: FactoryBot.create(:task) }
    APP_CONSTANTS['aco_measures_hqmf_set_ids'] = ['7B2A9277-43DA-4D99-9BEE-6AC271A07747']
  end

  def test_document_with_correct_tin
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 0, @validator.errors.count, "Expected 0 error, got #{@validator.errors}"
  end

  def test_document_with_incorrect_tin
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_single_code.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
    assert @validator.errors.map(&:message).include?('Reported TIN 1234567 does not match Expected TIN 1520670765.  You can configure expected TIN using Vendor Preferences.')
  end

  def test_document_with_no_tin
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_no_tin.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
    assert @validator.errors.map(&:message).include?('TIN should be reported for this measure to support ACO reporting.')
  end

  def test_no_warnings_when_not_aco_measure
    APP_CONSTANTS['aco_measures_hqmf_set_ids'] = ['6B2A9277-43DA-4D99-9BEE-6AC271A07747']
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good.xml')).read
    document = get_document(file)
    @validator.validate(document, @options)

    assert_equal 0, @validator.errors.count, "Expected 0 error, got #{@validator.errors}"
  end
end
