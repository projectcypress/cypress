# frozen_string_literal: true

require 'test_helper'
class ProgramValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = Validators::ProgramValidator.new(['HQR_PI'])
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good.xml')).read
    @document = get_document(file)
  end

  def test_document_missing_program_code
    @document.xpath('//cda:informationRecipient').each(&:remove)
    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
    msg = "Expected to find program(s) 'HQR_PI' but no program code was found."
    assert_equal msg, @validator.errors[0].message
  end

  def test_document_with_non_matching_program_code
    node = @document.at_xpath('//cda:informationRecipient/cda:intendedRecipient/cda:id/@extension')
    node.value = 'bobs_house'

    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
    msg = "CMS Program code 'bobs_house' does not match the expected code for program(s) HQR_PI."
    assert_equal msg, @validator.errors[0].message
  end

  def test_document_with_matching_program_code
    @validator.validate(@document)

    assert @validator.errors.empty?
  end
end
