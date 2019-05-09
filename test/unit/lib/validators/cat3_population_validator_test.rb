require 'test_helper'
class Cat3PopulationValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = Validators::Cat3PopulationValidator.new
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml')).read
    @document = get_document(file)
  end

  def test_document_with_bad_data
    numer_greater_than_denom(@document)

    @validator.validate(@document)

    assert_equal 1, @validator.errors.count

    expected_text_fmt = /Numerator value \d+ \+ Denominator Exclusions value \d+ \+ Denominator Exceptions value \d+ is greater than Denominator value \d+ for measure .*/

    assert @validator.errors[0].message.match(expected_text_fmt), 'Error message does not match the expected format'
  end

  def test_good_document
    @validator.validate(@document)

    assert_empty @validator.errors, "Expected no errors for good Cat 3 document, found #{@validator.errors}"
  end

  def test_no_exception_thrown_on_bad_document
    @document.xpath('/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component').each(&:remove)

    @validator.validate(@document)

    assert @validator.errors
  end

  def numer_greater_than_denom(doc)
    # TODO: Filter out continuous measures for this validation (and potentially others)
    # Find the NUMER and DENOM
    numer = doc.at_css('value[code="NUMER"] ~ entryRelationship[typeCode="SUBJ"] observation value')
    denom = doc.at_css('value[code="DENOM"] ~ entryRelationship[typeCode="SUBJ"] observation value')
    denom_value = denom.attributes['value'].value.to_i
    # Add a random amount to DENOM and store it in NUMER
    numer_value = denom_value + Random.new.rand(1..10)
    numer.attributes['value'].value = numer_value.to_s
  end
end
