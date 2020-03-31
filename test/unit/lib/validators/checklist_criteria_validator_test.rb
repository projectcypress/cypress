require 'test_helper'
class ChecklistCriteriaValidator < ActiveSupport::TestCase
  include ::Validators

  def setup
    product = FactoryBot.create(:product_static_bundle)
    @measure = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first
    @checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    @checklist_test.save!
    @validator = ChecklistCriteriaValidator.new(@checklist_test)

    bd = 75.years.ago
    @qdm_patient = QDM::Patient.new(birthDatetime: bd)
    @qdm_patient.extendedData = { 'medical_record_number' => '123' }
    @qdm_patient.dataElements << QDM::PatientCharacteristicBirthdate.new(birthDatetime: bd)
    @qdm_patient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [QDM::Code.new('2106-3', '2.16.840.1.113883.6.238', 'White', 'Race & Ethnicity - CDC')])
    @qdm_patient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [QDM::Code.new('2186-5', '2.16.840.1.113883.6.238', 'Not Hispanic or Latino', 'Race & Ethnicity - CDC')])
    @qdm_patient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [QDM::Code.new('M', '2.16.840.1.113883.12.1', 'Male', 'Administrative sex (HL7)')])
    @cqm_patient = CQM::Patient.new(givenNames: %w['First Middle'], familyName: 'Family', bundleId: '1')
    @options = { start_time: Date.new(2012, 1, 1), end_time: Date.new(2012, 12, 31) }
  end

  def setup_sdc(data_type, attribute_name, negated_valueset, recorded_result, attribute_code)
    data_type.codeListId = '1.3.4.5'
    atts = data_type.attributes.slice('qdmCategory', 'qdmStatus', '_type', 'hqmfOid', 'codeListId')
    atts['dataElementAttributes'] = [{ 'attribute_name' => attribute_name }]
    @checklist_test.checked_criteria.destroy_all
    @checklist_test.checked_criteria.new(attribute_index: 0,
                                         code: '1234',
                                         recorded_result: recorded_result,
                                         attribute_code: attribute_code,
                                         negated_valueset: negated_valueset,
                                         measure_id: @measure._id,
                                         passed_qrda: nil,
                                         source_data_criteria: atts)
    @checklist_test.save
  end

  def test_validate_good_files
    validator = CqmValidators::Cat1R52.instance
    cda_validator = CqmValidators::CDA.instance

    TEST_ATTRIBUTES.each do |ta|
      dt = QDM::PatientGeneration.generate_loaded_datatype(ta[6], ta[7])
      setup_sdc(dt.clone, ta[2], ta[3], ta[4], ta[5])
      test_specific_qdm_patient = qdm_patient_for_attribute(dt, ta, @qdm_patient)

      @cqm_patient.qdmPatient = test_specific_qdm_patient

      patient_xml = Qrda1R5.new(@cqm_patient, Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'), @options).render

      doc = Nokogiri::XML::Document.parse(patient_xml)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      @validator.validate(doc)

      begin
        exported_qrda = doc
        errors = validator.validate(exported_qrda)
        cda_errors = cda_validator.validate(exported_qrda)
        # File.write("script/checklist_errors/#{ta[6].gsub(/:/, '')}_#{ta[2]}.xml", exported_qrda.to_xml)
        errors.each do |error|
          puts "\e[31mSchematron Error In #{ta[0]}_#{ta[1]}: #{error.message}\e[0m"
        end
        cda_errors.each do |error|
          puts "\e[31mSchema Error In #{ta[0]}_#{ta[1]}: #{error.message}\e[0m"
        end
      rescue StandardError => e
        puts "\e[31mException validating #{ta[0]}_#{ta[1]}: #{e.message}\e[0m"
      end

      assert @checklist_test.checked_criteria.first[:passed_qrda], "should pass with a good file for #{ta[0]} #{ta[1]} with a #{ta[2]}"
    end
  end

  def test_validate_bad_files
    # bad deletes attribute, then confirms that we don't import it
    TEST_ATTRIBUTES.each do |ta|
      restricted_dt = QDM::PatientGeneration.generate_loaded_datatype(ta[6])
      setup_sdc(restricted_dt, ta[2], ta[3], ta[4], ta[5])

      restricted_dt.prescriberId = QDM::Identifier.new(namingSystem: '1.2.3.4', value: '1234') if restricted_dt.respond_to?(:prescriberId)
      restricted_dt.dispenserId = QDM::Identifier.new(namingSystem: '1.2.3.4', value: '1234') if restricted_dt.respond_to?(:dispenserId)

      restricted_dt.relevantDatetime = nil if restricted_dt.respond_to?(:relevantDatetime) && restricted_dt.respond_to?(:relevantPeriod) && ta[2] == 'relevantPeriod'
      restricted_dt.relevantPeriod = nil if restricted_dt.respond_to?(:relevantDatetime) && restricted_dt.respond_to?(:relevantPeriod) && ta[2] == 'relevantDatetime'

      restricted_dt[ta[2]] = nil
      remove_embeded_objects(restricted_dt, ta[2])

      test_specific_qdm_patient = @qdm_patient.clone
      test_specific_qdm_patient.dataElements << restricted_dt
      @cqm_patient.qdmPatient = test_specific_qdm_patient

      patient_xml = Qrda1R5.new(@cqm_patient, Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'), @options).render

      doc = Nokogiri::XML::Document.parse(patient_xml)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

      @validator.validate(doc)

      # File.write("script/checklist_without/#{ta[6].gsub(/:/, '')}_#{ta[2]}.xml", doc.to_xml)
      assert_nil @checklist_test.checked_criteria.first[:passed_qrda], "should fail with a bad file for #{ta[0]} #{ta[1]} without a #{ta[2]}"
    end
  end

  def remove_embeded_objects(restricted_dt, attribute_name)
    restricted_dt.performer.destroy if attribute_name == 'performer'
    restricted_dt.recorder.destroy if attribute_name == 'recorder'
    restricted_dt.requester.destroy if attribute_name == 'requester'
    restricted_dt.sender.destroy if attribute_name == 'sender'
    restricted_dt.recipient.destroy if attribute_name == 'recipient'
    restricted_dt.participant.destroy if attribute_name == 'participant'
    restricted_dt.prescriber.destroy if attribute_name == 'prescriber'
    restricted_dt.dispenser.destroy if attribute_name == 'dispenser'
  end
end
