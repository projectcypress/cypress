require 'test_helper'
require 'vcr_setup.rb'

class ApiMeasureEvaluatorTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  def setup
    @apime = Cypress::ApiMeasureEvaluator.new('test', 'test')
    import_bundle_and_create_product(retrieve_bundle)
  end

  def test_complete_roundtrip_using_real_bundle
    # Leverage using functions in the ApiMeasureEvaluator
    perform_filtering_tests
    perform_measure_tests
    failed_tests = TestExecution.where(state: { '$in': %w[failed errored] })
    assert failed_tests.empty?, "Test failed for #{failed_tests.first.task.product_test.cms_id} - #{failed_tests.collect { |ft| ft.execution_errors.collect(&:message) }}" unless failed_tests.empty?
  end

  # Get bundle from the demo server.  Use VCR if available
  def retrieve_bundle
    VCR.use_cassette('bundle_download') do
      bundle_resource = RestClient::Request.execute(method: :get,
                                                    url: 'https://cypress.healthit.gov/measure_bundles/fixture-bundle-2020.zip',
                                                    user: ENV['VSAC_USERNAME'],
                                                    password: ENV['VSAC_PASSWORD'],
                                                    raw_response: true,
                                                    headers: { accept: :zip })

      return bundle_resource.file
    end
  end

  # import @bundle from zip file, after complete, create @vendor and @product for use throughout
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
        # Pick 1 measure with an observation
        obs_measures = @bundle.measures.where(measure_scoring: { '$in': %w[RATIO CONTINUOUS_VARIABLE] }).distinct(:hqmf_id).sample(1)
        # Pick 2 random EH measures
        eh_measures = @bundle.measures.where(reporting_program_type: 'eh').distinct(:hqmf_id).sample(2)
        # Pick 8 random EP measures
        ep_measures = @bundle.measures.where(reporting_program_type: 'ep').distinct(:hqmf_id).sample(8)
        measure_ids = eh_measures + ep_measures + obs_measures
        @vendor = Vendor.find_or_create_by(name: 'MeasureEvaluationVendor')
        post :create, params: { vendor_id: @vendor.id, product: { name: 'MeasureEvaluationProduct', bundle_id: @bundle.id.to_s, c1_test: true, c2_test: true, c3_test: false, c4_test: true, duplicate_patients: false, randomize_patients: true, measure_ids: measure_ids } }
      end
    end
    @product = Product.where(name: 'MeasureEvaluationProduct').first
  end

  # run 2 of the 5 filtering tests for @product
  def perform_filtering_tests
    filtering_tests = @product.product_tests.filtering_tests
    # Save the Filter Test Deck, each filter test uses the same unfiltered test deck
    File.open('tmp/filter_patients.zip', 'wb') do |output|
      output.write(filtering_tests.first.patient_archive.read)
    end
    filtering_tests.each do |ft|
      # Since were are leveraging the ApiMeasureEvaluator, it uses JSON returned from the API to find filter criteria, stored as filter_test_parameters
      filter_test_parameters = {}
      # As the Admin user, use the ProductTestsController to find the filter criteria for the filtering test
      for_each_logged_in_user([ADMIN]) do
        @controller = ProductTestsController.new
        get :show, params: { format: :json, product_id: ft.product.id, id: ft.id }
        filter_test_parameters = JSON.parse(response.body)
      end
      # Using the filter criteria, filter
      filter_and_save_cat_1_zip(filter_test_parameters, ft)
      upload_test_artifacts('Cat1FilterTask', 'Cat3FilterTask', ft)
      delete_test_zip_files(ft)
    end
    File.delete('tmp/filter_patients.zip')
  end

  # Filter the 'filter_patients.zip' using the filter test parameters to create a new filtred zip file
  def filter_and_save_cat_1_zip(filter_test_parameters, filter_test)
    # Loop through all entries in filter_patients.zip
    Zip::ZipFile.open('tmp/filter_patients.zip') do |zipfile|
      zipfile.entries.each do |entry|
        doc = Nokogiri::XML(zipfile.read(entry))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        # do not include patient if they do not have required criteria
        next unless @apime.filter_out_patients(doc, filter_test_parameters)

        Zip::ZipFile.open("tmp/#{filter_test.id}.zip", Zip::File::CREATE) do |z|
          z.get_output_stream(entry) { |f| f.puts zipfile.read(entry) }
        end
      end
    end
  end

  def perform_measure_tests
    @product.product_tests.measure_tests.each do |mt|
      # Iterate through all patients and randomly swap relevant times. These will be reflected in the downloaded QRDA files.
      # When re-imported, the new calculations should match the expected.
      mt.patients.each do |patient|
        next unless [true, false].sample

        swap_relevant_times(patient)
        patient.save
      end
      # save test deck for measure test
      File.open("tmp/#{mt.id}.zip", 'wb') do |output|
        output.write(mt.tasks.c1_task.good_results)
      end
      upload_test_artifacts('C1Task', 'C2Task', mt)
      delete_test_zip_files(mt)
    end
  end

  # As the Admim user, use the test execution controller to submit results
  def upload_test_artifacts(cat_1_task_type, cat_3_task_type, product_test)
    @controller = TestExecutionsController.new
    perform_enqueued_jobs do
      for_each_logged_in_user([ADMIN]) do
        # Find the appropriate tasks for the type of test
        cat_1_task = product_test.tasks.where(_type: cat_1_task_type).first
        cat_3_task = product_test.tasks.where(_type: cat_3_task_type).first
        # We need to perform calculation before upload.  For Cat III file, and to remove patients that don't meet IPP
        calcuate_and_create_test_uploads(product_test)
        post :create, params: { task_id: cat_1_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{product_test.id}_only_ipp.zip"), 'application/zip') }
        post :create, params: { task_id: cat_3_task.id, results: Rack::Test::UploadedFile.new(File.new("tmp/#{product_test.id}.xml"), 'application/xml') }
      end
    end
  end

  def calcuate_and_create_test_uploads(product_test)
    # Hash to store the file_name (key) and the corresponding patient id (value)
    patient_id_file_map = {}

    # correlation_id for stored individual results
    correlation_id = "#{product_test.id}_u"

    import_cat1_zip(File.new("tmp/#{product_test.id}.zip"), patient_id_file_map)

    patients = Patient.find(patient_id_file_map.values)
    # We need to normalize_date_times prior to calculating our Cat III
    patients.map(&:normalize_date_times)

    successful_calculation = false
    until successful_calculation
      # Use ApiMeasureEvaluator to call cqm-execution-service
      @apime.do_calculation(product_test, patients, correlation_id)
      successful_calculation = IndividualResult.where(correlation_id: correlation_id, IPP: { '$gte' => 1 }).size.positive?
    end

    # Seed ExpectedResultsCalculator with patients and correlation_id for cat III generation
    erc = Cypress::ExpectedResultsCalculator.new(patients, correlation_id, product_test.effective_date)
    results = erc.aggregate_results_for_measures(product_test.measures)

    # Set the Submission Program to MIPS_INDIV if there is a C3 test and the test is for an ep measure.
    cat3_submission_program = if product_test&.product&.c3_test
                                product_test&.measures&.first&.reporting_program_type == 'ep' ? 'MIPS_INDIV' : false
                              else
                                false
                              end
    options = { provider: product_test.patients.first.providers.first, submission_program: cat3_submission_program,
                start_time: product_test.start_date, end_time: product_test.end_date }
    cat_3_xml = Qrda3R21.new(results, product_test.measures, options).render

    # Loop through all entries in product_test.zip to remove patients that do not meed IPP (i.e., do not have IndividualResult)
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

    # CLean up and remove all imported patients
    Patient.find(patient_id_file_map.values).each(&:destroy)

    File.write("tmp/#{product_test.id}.xml", cat_3_xml)
  end

  # Import all patients in the zip file, and maintain mapping between filename and id
  def import_cat1_zip(zip, patient_id_file_map)
    Zip::ZipFile.open(zip.path) do |zip_file|
      zip_file.entries.each do |entry|
        # Use ApiMeasureEvaluator to build nokogiri document
        doc = @apime.build_document(zip_file.read(entry))
        patient_id = import_cat1_file(doc)
        patient_id_file_map[entry.name] = patient_id
      end
    end
  end

  # Import and save Cat I file
  def import_cat1_file(doc)
    patient, _warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
    Cypress::QRDAPostProcessor.replace_negated_codes(patient, @bundle)
    patient.update(_type: CQM::TestExecutionPatient, correlation_id: 'api_eval', bundleId: @bundle.id)
    patient.save!
    patient.id
  end

  def delete_test_zip_files(test)
    File.delete("tmp/#{test.id}_only_ipp.zip")
    File.delete("tmp/#{test.id}.zip")
    File.delete("tmp/#{test.id}.xml")
  end

  # if a data element uses relevant dateTime, swap to relevant period
  # if a data element uses relevant period, swap to relevant dateTime
  def swap_relevant_times(patient)
    patient.qdmPatient.dataElements.each do |de|
      next unless de.respond_to?(:relevantDatetime) && de.respond_to?(:relevantPeriod)

      if de.relevantDatetime
        de.relevantPeriod = QDM::Interval.new(de.relevantDatetime, de.relevantDatetime).shift_dates(0)
        de.relevantDatetime = nil
      elsif de.relevantPeriod
        # Don't swap Relevant Periods that are ongoing or longer than 1 minute
        next if de.relevantPeriod.high.nil? || de.relevantPeriod.low.nil?
        next if ((de.relevantPeriod.high - de.relevantPeriod.low) / 60) > 1

        de.relevantDatetime = de.relevantPeriod.low
        de.relevantPeriod = nil
      end
    end
  end
end
