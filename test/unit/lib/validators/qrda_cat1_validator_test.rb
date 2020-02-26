require 'test_helper'
class QrdaCat1ValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @bundle = FactoryBot.create(:static_bundle)
    @measures = [Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first]
    @validator_with_c3 = QrdaCat1Validator.new(@bundle, true, true, false, @measures)
    @validator_without_c3 = QrdaCat1Validator.new(@bundle, false, false, false, @measures)
    @task = C1Task.new
  end

  def test_validate_good_file
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_good.xml')).read
    @validator_with_c3.validate(file, task: @task)
    assert_empty @validator_with_c3.errors

    @validator_without_c3.validate(file, task: @task)
    assert_empty @validator_without_c3.errors
  end

  def test_validate_file_with_encounter_schematron_error
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_error_in_encounter.xml')).read
    @validator_with_c3.validate(file, task: @task)

    assert @validator_with_c3.errors.any? { |error| error.validator == 'CqmValidators::Cat1R51' }, 'There should be atleast one QRDA schematron error'

    @validator_without_c3.validate(file, task: @task)
    assert @validator_without_c3.errors.any? { |error| error.validator == 'CqmValidators::Cat1R51' }, 'There should be atleast one QRDA schematron error'
  end

  def test_bad_schema
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_bad_schema.xml')).read
    @validator_with_c3.validate(file, task: @task)

    errors = @validator_with_c3.errors
    assert_not_empty errors
    errors.each do |e|
      assert_equal :error, e.msg_type, 'All validation messages should be errors for a bad schema'
    end
  end

  def test_single_code_error
    @product_test = FactoryBot.create(:product_test_static_result)
    @calc_validator_with_c3 = CalculatingSmokingGunValidator.new(@product_test.measures, @product_test.patients, @product_test.id)
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_single_code.xml')).read
    doc = Nokogiri::XML(file)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    @calc_validator_with_c3.parse_record(doc, file_name: 'sample_patient_single_code')
    errors = @calc_validator_with_c3.errors
    assert_not_empty errors
    errors.each do |e|
      assert e.message.include?('CMS QRDA Implementation Guide, Section 5.2.3.1'), 'All validation errors should show single code negation error'
    end
  end
end
