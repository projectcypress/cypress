require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  def setup
    @bundle = FactoryBot.create(:static_bundle)
  end

  def test_record_knows_bundle
    patient = BundlePatient.new(bundleId: @bundle.id)
    patient.save
    assert_equal @bundle, patient.bundle, 'A record should know what bundle it is associated with if any'
  end

  def test_record_should_be_able_to_find_calculation_results
    r = Patient.where(familyName: 'MPL record').first
    assert_equal 5, r.calculation_results.count, 'record should have 5 calculated results. 1 for the proportion measure and 4 for the stratified measure'
  end

  def record_demographics_equal?(r1, r2)
    r1.givenNames == r2.givenNames && r1.familyName == r2.familyName && r1.gender == r2.gender &&
      r1.qdmPatient.birthDatetime == r2.qdmPatient.birthDatetime && r1.race['code'] == r2.race['code'] && r1.ethnicity['code'] == r2.ethnicity['code']
  end

  def record_birthyear_equal?(r1, r2)
    r1.qdmPatient.birthDatetime.year == r2.qdmPatient.birthDatetime.year
  end
end
