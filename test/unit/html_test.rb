require 'test_helper'

class HTMLTest < ActiveSupport::TestCase
  def setup
    @measure = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first

    bd = 75.years.ago
    @qdm_patient = QDM::Patient.new(birthDatetime: bd)
    @qdm_patient.extendedData = { 'medical_record_number' => '123' }
    @qdm_patient.dataElements << QDM::PatientCharacteristicBirthdate.new(birthDatetime: bd)
    @qdm_patient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [QDM::Code.new('2106-3', '2.16.840.1.113883.6.238', 'White', 'Race & Ethnicity - CDC')])
    @qdm_patient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [QDM::Code.new('2186-5', '2.16.840.1.113883.6.238', 'Not Hispanic or Latino', 'Race & Ethnicity - CDC')])
    @qdm_patient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [QDM::Code.new('M', '2.16.840.1.113883.12.1', 'Male', 'Administrative sex (HL7)')])
    @cqm_patient = CQM::Patient.new(givenNames: %w['First Middle'], familyName: 'Family', bundleId: '1')
  end

  def test_all_html_attributes
    TEST_ATTRIBUTES.each do |ta|
      dt = QDM::PatientGeneration.generate_loaded_datatype(ta[6], ta[7])
      qdm_patient = qdm_patient_for_attribute(dt, ta, @qdm_patient)
      @cqm_patient.qdmPatient = qdm_patient

      # create full Patient
      formatter = Cypress::HTMLExporter.new([@measure], Date.new(2012, 1, 1), Date.new(2012, 12, 31))
      html = formatter.export(@cqm_patient)
      assert html.include?(ta[6]), "html should include QDM type #{ta[6]}"
      assert dt.respond_to?(ta[2]), "datatype generation discrepancy, should contain field #{ta[2]}"

      if dt[ta[2]].respond_to?(:strftime)
        # timey object
        formatted_date = dt[ta[2]].strftime('%FT%T')
        assert html.include?(formatted_date), "html should include date/time value #{formatted_date}"
      elsif dt[ta[2]].is_a?(Array)
        # components, relatedTo (irrelevant), facilityLocations, diagnoses (all code or nested code)
        dt[ta[2]].each do |attr_elem|
          if attr_elem.code.is_a?(Hash)
            # nested code
            assert html.include?(attr_elem.code.code), "html should include nested code value #{attr_elem.code.code}"
          else
            # code
            assert html.include?(attr_elem.code), "html should include code value #{attr_elem.code}"
          end
        end
      elsif dt[ta[2]].is_a?(Integer) || dt[ta[2]].is_a?(String) || dt[ta[2]].is_a?(Float)
        assert html.include?(dt[ta[2]].to_s), "html should include text value #{dt[ta[2]]}"

      elsif dt[ta[2]].key?(:low)
        # interval (may or may not include high)
        formatted_date = dt[ta[2]].low.strftime('%FT%T')
        assert html.include?(formatted_date), "html should include low value #{formatted_date}"
      elsif dt[ta[2]].key?(:value)
        # value for basic identifier, result, or quantity (may or may not include unit)
        # must come before code to match result logic
        assert html.include?(dt[ta[2]].value.to_s), "html should include value #{dt[ta[2]].value}"
      elsif dt[ta[2]].key?(:code) || dt[ta[2]].key?('code')
        # must come after value to match result logic
        if dt[ta[2]].code.is_a?(Hash)
          # nested code
          assert html.include?(dt[ta[2]].code.code), "html should include nested code value #{dt[ta[2]].code.code}"
        else
          # code
          assert html.include?(dt[ta[2]].code), "html should include code value #{dt[ta[2]].code}"
        end
      elsif dt[ta[2]].key?('identifier')
        # entity
        assert html.include?(dt[ta[2]].identifier.value), "html should include identifier value #{dt[ta[2]].identifier.value}"
      else
        # simple to_s, unlikely to get here
        assert html.include?(dt[ta[2]].to_s), "html should include text value #{dt[ta[2]]}"
      end
    end
  end
end
