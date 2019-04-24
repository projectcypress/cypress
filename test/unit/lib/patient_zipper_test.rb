require 'test_helper'
require 'fileutils'

class PatientZipperTest < ActiveSupport::TestCase
  setup do
    pt = FactoryBot.create(:product_test_static_result)
    @static_patient = FactoryBot.create(:static_test_patient, bundleId: pt.bundle.id)
    @static_patient.save
    @patients = Patient.all.to_a.select { |p| p.gender == 'F' }

    prov = Provider.default_provider

    @patients.each do |p|
      p.providers << prov
      p.save!
    end
  end

  test 'Should create valid html file' do
    format = :html
    filename = "pTest-#{Time.now.to_i}.html.zip"
    file = Tempfile.new(filename)
    Cypress::PatientZipper.zip(file, @patients, format)
    file.close
    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
      if zip_entry.name.include?('.html') && !zip_entry.name.include?('__MACOSX')
        doc = Nokogiri::HTML(zip_entry.get_input_stream, &:strict)
        doc.at_css('head title').to_s
        count += 1
      end
    end
    File.delete(file.path)
    assert_equal @patients.count, count, 'Zip file has wrong number of records'
  end

  test 'Should create valid qrda file with a negated valueset' do
    format = :qrda
    filename = "pTest-#{Time.now.to_i}.qrda.zip"
    file = Tempfile.new(filename)

    patient = @static_patient
    modified_procedure = patient.qdmPatient.procedures.first
    modified_procedure.negationRationale = modified_procedure.codes.first
    original_code = modified_procedure.codes.first.code
    patient.save

    Cypress::PatientZipper.zip(file, [patient], format)
    file.close

    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
      if zip_entry.name.include?('.xml') && !zip_entry.name.include?('__MACOSX')
        doc = Nokogiri::XML(zip_entry.get_input_stream, &:strict)
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        assert_equal 1, doc.xpath('//cda:code[@nullFlavor="NA"]').size, 'There should be 1 negated code in the exported QRDA'
        confirm_imported_patient_can_be_saved_after_replaced_codes(doc, patient, original_code)
        count += 1
      end
    end
    File.delete(file.path)
    assert_equal 1, count, 'Zip should contain 1 QRDA file for the patient with a negated valueset'
  end

  def confirm_imported_patient_can_be_saved_after_replaced_codes(doc, patient, original_code)
    negated_oid = ValueSet.where('concepts.code': original_code).first.oid
    imported_patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
    imported_patient.update(_type: CQM::VendorPatient)
    cloned_import = imported_patient.clone
    codefound = imported_patient.qdmPatient.procedures.first.dataElementCodes.any? { |dec| dec[:code] == original_code }
    assert_equal false, codefound, 'code should not be found prior to replace_negated_codes'
    Cypress::GoImport.replace_negated_codes(imported_patient, patient.bundle)
    codefound = imported_patient.qdmPatient.procedures.first.dataElementCodes.any? { |dec| dec[:code] == original_code }
    assert codefound, 'replaced code should equal original code'
    assert imported_patient.save
    APP_CONSTANTS['version_config']['~>2018.0.0']['default_negation_codes'][negated_oid] = { 'code' => '123', 'codeSystem' => 'SNOMEDCT' }
    Cypress::GoImport.replace_negated_codes(cloned_import, patient.bundle)
    codefound = cloned_import.qdmPatient.procedures.first.dataElementCodes.any? { |dec| dec[:code] == '123' }
    assert codefound, 'replaced code should equal default code'
    assert cloned_import.save
  end

  test 'Should create valid qrda file' do
    format = :qrda
    filename = "pTest-#{Time.now.to_i}.qrda.zip"
    file = Tempfile.new(filename)

    Cypress::PatientZipper.zip(file, @patients, format)
    file.close

    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
      if zip_entry.name.include?('.xml') && !zip_entry.name.include?('__MACOSX')
        Nokogiri::XML(zip_entry.get_input_stream, &:strict)
        count += 1
      end
    end
    File.delete(file.path)
    assert_equal @patients.count, count, 'Zip file has wrong number of records'
  end

  test 'Should create valid qrda file when not associated to test' do
    @patients = Patient.where(correlation_id: nil)

    format = :qrda
    filename = "pTest-#{Time.now.to_i}.qrda.zip"
    file = Tempfile.new(filename)

    Cypress::PatientZipper.zip(file, @patients, format)
    file.close

    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
      if zip_entry.name.include?('.xml') && !zip_entry.name.include?('__MACOSX')
        Nokogiri::XML(zip_entry.get_input_stream, &:strict)
        count += 1
      end
    end
    File.delete(file.path)
    assert_equal @patients.count, count, 'Zip file has wrong number of records'
  end
end
