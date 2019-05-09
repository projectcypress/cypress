require 'test_helper'
class EncounterValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = Validators::EncounterValidator.new
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'good_cat1_single_encounter.xml')).read
    @document = get_document(file)
  end

  def test_document_with_correct_encounter_times
    @validator.validate(@document)

    assert_equal 0, @validator.errors.count, "Expected 0 error, got #{@validator.errors}"
  end

  def test_start_after_end
    change_encounter_period(@document, '20160829160000', '20160829150000')
    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
  end

  def test_start_date_too_long
    change_encounter_period(@document, '201608281400000000000', '20160829150000')
    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
  end

  def test_end_date_too_long
    change_encounter_period(@document, '20160828140000', '201608291500000000000')
    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
  end

  def test_end_date_in_the_future
    change_encounter_period(@document, '20160829140000', '20200829150000')
    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
  end

  def test_no_time
    @document.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.23"] ~ effectiveTime low').remove
    @validator.validate(@document)

    assert_equal 1, @validator.errors.count, "Expected 1 error, got #{@validator.errors}"
  end

  # borrowed from cedar
  def change_encounter_period(doc, new_start, new_end)
    # Mangle the start of the reporting period
    start = doc.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.23"] ~ effectiveTime low')
    start.attributes['value'].value = new_start
    # Mangle the end of the reporting period
    finish = doc.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.23"] ~ effectiveTime high')
    finish.attributes['value'].value = new_end
  end
end
