require 'test_helper'
require 'vcr_setup.rb'

class ApiMeasureEvaluatorTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  # def setup
  #   @vcr_options = {match_requests_on: [:method, :uri_no_st]}
  # end

  def test_complete_roundtrip_using_real_bundle
    bundle_id = nil
    measure_ids = []
    FactoryBot.create(:admin_user)
    @controller = ProductsController.new
    for_each_logged_in_user([ADMIN]) do
      perform_enqueued_jobs do
        bundle_id = Cypress::CqlBundleImporter.import(import_bundle, Tracker.new, false).id.to_s
        measure_ids = Measure.distinct(:hqmf_id).sample(10)
        vendor = Vendor.find_or_create_by(name: 'MeasureEvaluationVendor')
        post :create, params: { vendor_id: vendor.id, product: { name: 'MeasureEvaluationProduct', bundle_id: bundle_id, c1_test: true, c2_test: true, c3_test: true, c4_test: true, duplicate_patients: false, randomize_patients: true, measure_ids: measure_ids } }
      end
    end
    product = Product.all.first
    checklist_test = product.product_tests.build({ name: 'record sample test', measure_ids: measure_ids[0, 1] }, ChecklistTest)
    product.save!
    checklist_test.tasks.create!({}, C1ChecklistTask)
    apime = Cypress::ApiMeasureEvaluator.new('test', 'test')
    first_filter_test = FilteringTest.all.first
    File.open('tmp/filter_patients.zip', 'wb') do |output|
      output.write(first_filter_test.patient_archive.read)
    end
    sampled_filtering_tests = FilteringTest.all.sample(2)
    sampled_filtering_tests.each do |ft|
      product_test_hash = {}
      for_each_logged_in_user([ADMIN]) do
        @controller = ProductTestsController.new
        get :show, params: { format: :json, product_id: ft.product.id, id: ft.id }
        product_test_hash = JSON.parse(response.body)
      end
      file_name = "#{ft.id}.zip".tr(' ', '_')
      Zip::ZipFile.open('tmp/filter_patients.zip') do |zipfile|
        zipfile.entries.each do |entry|
          doc = Nokogiri::XML(zipfile.read(entry))
          doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
          doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
          next unless apime.filter_out_patients(doc, product_test_hash)

          Zip::ZipFile.open("tmp/#{file_name}", Zip::File::CREATE) do |z|
            z.get_output_stream(entry) { |f| f.puts zipfile.read(entry) }
          end
        end
      end
    end
    sampled_filtering_tests.each do |ft|
      @controller = TestExecutionsController.new
      perform_enqueued_jobs do
        for_each_logged_in_user([ADMIN]) do
          cat_1_task = ft.tasks.where(_type: 'Cat1FilterTask').first
          cat_3_task = ft.tasks.where(_type: 'Cat3FilterTask').first
          calcuate_cat_3(ft, bundle_id)
          post :create, params: { task_id: cat_1_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{ft.id}_only_ipp.zip"), 'application/zip') }
          post :create, params: { task_id: cat_3_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{ft.id}.xml"), 'application/xml') }
          File.delete("tmp/#{ft.id}_only_ipp.zip")
          File.delete("tmp/#{ft.id}.zip")
          File.delete("tmp/#{ft.id}.xml")
        end
      end
    end
    File.delete('tmp/filter_patients.zip')
    MeasureTest.each do |mt|
      @controller = TestExecutionsController.new
      perform_enqueued_jobs do
        for_each_logged_in_user([ADMIN]) do
          cat_1_task = mt.tasks.where(_type: 'C1Task').first
          cat_3_task = mt.tasks.where(_type: 'C2Task').first
          file_name = "#{mt.id}.zip".tr(' ', '_')
          File.open("tmp/#{file_name}", 'wb') do |output|
            output.write(mt.patient_archive.read)
          end
          calcuate_cat_3(mt, bundle_id)
          post :create, params: { task_id: cat_1_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{mt.id}_only_ipp.zip"), 'application/zip') }
          post :create, params: { task_id: cat_3_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{mt.id}.xml"), 'application/xml') }
          File.delete("tmp/#{mt.id}_only_ipp.zip")
          File.delete("tmp/#{mt.id}.zip")
          File.delete("tmp/#{mt.id}.xml")
        end
      end
    end
    assert_equal 0, TestExecution.where(state: 'failed').size
  end

  def calcuate_cat_3(product_test, bundle_id)
    patient_id_file_map = {}

    correlation_id = "#{product_test.id}_u"

    import_cat1_zip(File.new("tmp/#{product_test.id}.zip"), patient_id_file_map, bundle_id)
    do_calculation_cqm_execution(product_test, Patient.find(patient_id_file_map.values), correlation_id)

    erc = Cypress::ExpectedResultsCalculator.new(Patient.find(patient_id_file_map.values), correlation_id, product_test.effective_date)
    results = erc.aggregate_results_for_measures(product_test.measures)

    cms_compatibility = product_test&.product&.c3_test
    options = { provider: product_test.patients.first.providers.first, submission_program: cms_compatibility,
                start_time: product_test.start_date, end_time: product_test.end_date }
    xml = Qrda3R21.new(results, product_test.measures, options).render

    Zip::ZipFile.open("tmp/#{product_test.id}.zip") do |zipfile|
      zipfile.entries.each do |entry|
        doc = Nokogiri::XML(zipfile.read(entry))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        next unless CQM::IndividualResult.where(patient_id: patient_id_file_map[entry.name]).size.positive?

        Zip::ZipFile.open("tmp/#{product_test.id}_only_ipp.zip", Zip::File::CREATE) do |z|
          z.get_output_stream(entry) { |f| f.puts zipfile.read(entry) }
        end
      end
    end

    Patient.find(patient_id_file_map.values).each(&:destroy)

    File.write("tmp/#{product_test.id}.xml", xml)
  end

  def do_calculation_cqm_execution(product_test, patients, correlation_id)
    measures = product_test.measures
    calc_job = Cypress::CqmExecutionCalc.new(patients.map(&:qdmPatient), measures, correlation_id,
                                             effectiveDateEnd: Time.at(product_test.effective_date).in_time_zone.to_formatted_s(:number),
                                             effectiveDate: Time.at(product_test.measure_period_start).in_time_zone.to_formatted_s(:number))
    calc_job.execute
  end

  def import_cat1_zip(zip, patient_id_file_map, bundle_id)
    Zip::ZipFile.open(zip.path) do |zip_file|
      zip_file.entries.each do |entry|
        doc = build_document(zip_file.read(entry))
        patient_id = import_cat1_file(doc, bundle_id)
        patient_id_file_map[entry.name] = patient_id
      end
    end
  end

  def build_document(document)
    doc = document.is_a?(Nokogiri::XML::Document) ? document : Nokogiri::XML(document.to_s)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    doc
  end

  def import_cat1_file(doc, bundle_id)
    patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
    Cypress::QRDAPostProcessor.replace_negated_codes(patient, Bundle.find(bundle_id))
    patient.update(_type: CQM::TestExecutionPatient, correlation_id: 'api_eval')
    patient.save!
    patient.id
  end

  def import_bundle
    VCR.use_cassette('bundle_download') do
      bundle_resource = RestClient::Request.execute(method: :get,
                                                    url: 'https://cypress.healthit.gov/measure_bundles/test-bundle.zip',
                                                    user: ENV['VSAC_USERNAME'],
                                                    password: ENV['VSAC_PASSWORD'],
                                                    raw_response: true,
                                                    headers: { accept: :zip })

      return bundle_resource.file
    end
  end
end
