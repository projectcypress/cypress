# frozen_string_literal: true

require 'test_helper'
require 'vcr_setup'

class HTMLTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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
          next if %w[QDM::Organization QDM::CarePartner QDM::Location QDM::Practitioner QDM::PatientEntity].include?(attr_elem._type)

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
      elsif dt[ta[2]].respond_to?(:low)
        # interval (may or may not include high)
        formatted_date = dt[ta[2]].low.strftime('%FT%T')
        assert html.include?(formatted_date), "html should include low value #{formatted_date}"
      elsif dt[ta[2]].respond_to?(:code)
        verify_code_in_html(dt[ta[2]], html)
      elsif dt[ta[2]].respond_to?(:value)
        verify_value_in_html(dt[ta[2]], html)
      elsif dt[ta[2]].key?(:code)
        verify_code_in_html(dt[ta[2]], html)
      elsif dt[ta[2]].key?(:value)
        verify_value_in_html(dt[ta[2]], html)
      elsif dt[ta[2]].key?('identifier')
        # entity
        assert html.include?(dt[ta[2]].identifier.value), "html should include identifier value #{dt[ta[2]].identifier.value}"
      else
        # simple to_s, unlikely to get here
        assert html.include?(dt[ta[2]].to_s), "html should include text value #{dt[ta[2]]}"
      end
    end
  end

  def verify_code_in_html(element, html)
    # must come after value to match result logic
    if element.code.is_a?(Hash)
      # nested code
      assert html.include?(element.code.code), "html should include nested code value #{element.code.code}"
    else
      # code
      code = element.code.respond_to?(:code) ? element.code.code : element.code
      assert html.include?(code), "html should include code value #{code}"
    end
  end

  def verify_value_in_html(element, html)
    # value for basic identifier, result, or quantity (may or may not include unit)
    # must come before code to match result logic
    assert html.include?(element.value.to_s), "html should include value #{element.value}"
  end

  def test_display_codes
    perform_enqueued_jobs do
      @bundle = Cypress::CqlBundleImporter.import(retrieve_mini_bundle, Tracker.new, include_highlighting: false)
    end

    # use file with negation
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'sample_patient_single_code.xml')).read
    doc = Nokogiri::XML(file)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

    # import and build code descriptions
    patient, _warnings, codes = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
    Cypress::QRDAPostProcessor.build_code_descriptions(codes, patient, @bundle)
    patient['bundleId'] = @bundle.id
    patient.update(_type: CQM::BundlePatient, correlation_id: @bundle.id)
    Cypress::QRDAPostProcessor.replace_negated_codes(patient, @bundle)
    patient.save!
    saved_patient = Patient.find(patient.id)

    # export to html
    formatter = Cypress::HTMLExporter.new([Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first], Date.new(2012, 1, 1), Date.new(2012, 12, 31))
    html = formatter.export(saved_patient)

    # initial html
    assert html.include?('Male'), 'HTML should include gender code description'
    assert html.include?('American Indian or Alaska Native'), 'HTML should include race code description'
    assert html.include?('Not Hispanic or Latino'), 'HTML should include ethnicity code description'
    assert html.include?('MEDICARE'), 'HTML should include payer code description'
    assert html.include?('Procedure contraindicated (situation)'), 'HTML should include negation rationale code description'
    assert html.include?('carvedilol 6.25 MG Oral Tablet'), 'HTML should include medication code description'
    # NOTE: code="60" from sdtc:valueSet="1.3.4.5" is unknown (fake) and therefore appropriately omits a description

    # randomize patient and re-export
    Cypress::DemographicsRandomizer.randomize(saved_patient, Random.new(Random.new_seed))
    Cypress::DemographicsRandomizer.update_demographic_codes(saved_patient)
    html = formatter.export(saved_patient)

    # assertions
    # check if race and ethnicity updated
    race_same = saved_patient.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first.code == '1002-5'
    assert_not html.include?('American Indian or Alaska Native'), 'HTML should include race code description' unless race_same
    ethnicity_same = saved_patient.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first.code == '2186-5'
    assert_not html.include?('Not Hispanic or Latino'), 'HTML should include ethnicity code description' unless ethnicity_same

    assert html.include?('Procedure contraindicated (situation)'), 'HTML should include negation rationale code description'
    assert html.include?('carvedilol 6.25 MG Oral Tablet'), 'HTML should include medication code description'
  end

  # Get bundle from the demo server.  Use VCR if available
  def retrieve_mini_bundle
    VCR.use_cassette('mini_bundle_download') do
      bundle_resource = RestClient::Request.execute(method: :get,
                                                    url: 'https://cypress.healthit.gov/measure_bundles/mini-fixture-bundle-2020.0.3.zip',
                                                    user: ENV['VSAC_USERNAME'],
                                                    password: ENV['VSAC_PASSWORD'],
                                                    raw_response: true,
                                                    headers: { accept: :zip })

      return bundle_resource.file
    end
  end
end
