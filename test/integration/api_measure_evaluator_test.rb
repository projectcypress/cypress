require 'test_helper'
require 'vcr_setup.rb'

class ApiMeasureEvaluatorTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  def test_complete_roundtrip_using_real_bundle
    @apime = Cypress::ApiMeasureEvaluator.new('test', 'test')
    import_bundle_and_create_product(retrieve_bundle)
    perform_filtering_tests
    perform_measure_tests
    assert_equal 0, TestExecution.where(state: 'failed').size
  end

  def retrieve_bundle
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

  def import_bundle_and_create_product(bundle_zip)
    # Create admin user
    FactoryBot.create(:admin_user)
    # Set controller to products controller
    @controller = ProductsController.new
    # As the Admin user, use the Products controller to create a product with C1/C2/C3 and C4 tests for 10 random measures
    for_each_logged_in_user([ADMIN]) do
      perform_enqueued_jobs do
        # Import the bundle
        @bundle = Cypress::CqlBundleImporter.import(bundle_zip, Tracker.new, false)
        # Pick out 10 random measures
        measure_ids = @bundle.measures.distinct(:hqmf_id).sample(10)
        @vendor = Vendor.find_or_create_by(name: 'MeasureEvaluationVendor')
        post :create, params: { vendor_id: @vendor.id, product: { name: 'MeasureEvaluationProduct', bundle_id: @bundle.id.to_s, c1_test: true, c2_test: true, c3_test: true, c4_test: true, duplicate_patients: false, randomize_patients: true, measure_ids: measure_ids } }
      end
    end
    @product = Product.where(name: 'MeasureEvaluationProduct').first
  end

  def perform_filtering_tests
    filtering_tests = @product.product_tests.filtering_tests
    # Save the Filter Test Deck
    File.open('tmp/filter_patients.zip', 'wb') do |output|
      output.write(filtering_tests.first.patient_archive.read)
    end
    sampled_filtering_tests = filtering_tests.sample(2)
    # Test 2 out of the 5 filtering tests
    sampled_filtering_tests.each do |ft|
      # Since were are leveraging the ApiMeasureEvaluator, it uses JSON returned from the API to find filter criteria, stored as filter_test_json
      filter_test_parameters = {}
      for_each_logged_in_user([ADMIN]) do
        @controller = ProductTestsController.new
        get :show, params: { format: :json, product_id: ft.product.id, id: ft.id }
        filter_test_parameters = JSON.parse(response.body)
      end
      created_filtered_uploads(filter_test_parameters, ft)
    end
    sampled_filtering_tests.each do |ft|
      upload_test_artifacts('Cat1FilterTask', 'Cat3FilterTask', ft)
      delete_test_zip_files(ft)
    end
    File.delete('tmp/filter_patients.zip')
  end

  def created_filtered_uploads(filter_test_parameters, filter_test)
    # Loop through filter test
    Zip::ZipFile.open('tmp/filter_patients.zip') do |zipfile|
      zipfile.entries.each do |entry|
        doc = Nokogiri::XML(zipfile.read(entry))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        next unless @apime.filter_out_patients(doc, filter_test_parameters)

        Zip::ZipFile.open("tmp/#{filter_test.id}.zip", Zip::File::CREATE) do |z|
          z.get_output_stream(entry) { |f| f.puts zipfile.read(entry) }
        end
      end
    end
  end

  def perform_measure_tests
    @product.product_tests.measure_tests.each do |mt|
      File.open("tmp/#{mt.id}.zip", 'wb') do |output|
        output.write(mt.patient_archive.read)
      end
      upload_test_artifacts('C1Task', 'C2Task', mt)
      delete_test_zip_files(mt)
    end
  end

  def upload_test_artifacts(cat_1_task_type, cat_3_task_type, product_test)
    @controller = TestExecutionsController.new
    perform_enqueued_jobs do
      for_each_logged_in_user([ADMIN]) do
        cat_1_task = product_test.tasks.where(_type: cat_1_task_type).first
        cat_3_task = product_test.tasks.where(_type: cat_3_task_type).first
        calcuate_and_create_test_uploads(product_test)
        post :create, params: { task_id: cat_1_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{product_test.id}_only_ipp.zip"), 'application/zip') }
        post :create, params: { task_id: cat_3_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{product_test.id}.xml"), 'application/xml') }
      end
    end
  end

  def calcuate_and_create_test_uploads(product_test)
    patient_id_file_map = {}

    correlation_id = "#{product_test.id}_u"

    import_cat1_zip(File.new("tmp/#{product_test.id}.zip"), patient_id_file_map)
    @apime.do_calculation_cqm_execution(product_test, Patient.find(patient_id_file_map.values), correlation_id)

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

  def import_cat1_zip(zip, patient_id_file_map)
    Zip::ZipFile.open(zip.path) do |zip_file|
      zip_file.entries.each do |entry|
        doc = @apime.build_document(zip_file.read(entry))
        patient_id = import_cat1_file(doc)
        patient_id_file_map[entry.name] = patient_id
      end
    end
  end

  def import_cat1_file(doc)
    patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
    Cypress::QRDAPostProcessor.replace_negated_codes(patient, @bundle)
    patient.update(_type: CQM::TestExecutionPatient, correlation_id: 'api_eval')
    patient.save!
    patient.id
  end

  def delete_test_zip_files(test)
    File.delete("tmp/#{test.id}_only_ipp.zip")
    File.delete("tmp/#{test.id}.zip")
    File.delete("tmp/#{test.id}.xml")
  end
end
