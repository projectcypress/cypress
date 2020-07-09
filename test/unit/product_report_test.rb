require 'test_helper'

class ProductReportTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include Cypress::ErrorCollector
  include ActiveJob::TestHelper

  setup do
    @user = FactoryBot.create(:atl_user)
    @product_test = FactoryBot.create(:cv_product_test_static_result)
    @first_product = @product_test.product
    @first_product.c3_test = true
    checklist_test = @first_product.product_tests.checklist_tests.first
    checklist_test.tasks.create({}, C3ChecklistTask)
    checklist_test.save
    @product_test.tasks.create({}, C1Task)
    @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.tasks.create({}, C3Cat1Task)
    @product_test.tasks.create({}, C3Cat3Task)
    @product_test.save
    @vendor = @product_test.product.vendor
  end

  # Key is the Class the error is reported from
  # 'factory_name' is the factory used to generate the error message
  # 'report_text' is a subset of the error message that we will use to determine if it exists in the product report
  TEST_EXECUTION_ERROR_HASH = {
    'CalculatingSmokingGunValidator' => [
      {
        'report_text' => 'does not match expected value',
        'factory_name' => :calculating_smoking_gun_validator_compare_results
      },
      {
        'report_text' => 'Interval with nullFlavor low time and nullFlavor high time',
        'factory_name' => :calculating_smoking_gun_validator_qrda_import_warning
      }
    ],
    'Cat3PopulationValidator' => [
      {
        'factory_name' => :cat3_population_validator_validate_populations,
        'report_text' => 'greater than Initial Population'
      }
    ],
    'ChecklistTest' => [
      {
        'factory_name' => :checklist_test_build_execution_errors_for_incomplete_checked_criteria,
        'report_text' => 'CMS159v8 - patient_characteristic, expired not complete'
      }
    ],
    'CMSPopulationCountValidator' => [
      {
        'factory_name' => :cms_population_count_validator_verify_all_codes_reported,
        'report_text' => 'all PAYER codes present'
      }
    ],
    'CMSProgramTest' => [
      {
        'factory_name' => :cms_program_test_build_execution_errors_for_incomplete_cms_criteria,
        'report_text' => 'Tax Identification Number not complete'
      }
    ],
    'CMSSchematronValidator' => [
      {
        'factory_name' => :cms_schematron_validator_validate,
        'report_text' => 'CONF:CMS_3'
      }
    ],
    'EHRCertificationIdValidator' => [
      {
        'factory_name' => :ehr_certification_id_validator_validate,
        'report_text' => 'CMS EHR Certification ID'
      }
    ],
    'EncounterValidator' => [
      {
        'factory_name' => :encounter_validator_validate_encounter_start_end,
        'report_text' => 'before start time'
      },
      {
        'factory_name' => :encounter_validator_get_time_value,
        'report_text' => 'CMS_0075'
      }
    ],
    'ExpectedResultsValidator' => [
      {
        'factory_name' => :expected_results_validator_generate_could_not_find_population_error_message,
        'report_text' => 'Could not find value for Population IPP'
      },
      {
        'factory_name' => :expected_results_validator_generate_could_not_find_population_stratification_error_message,
        'report_text' => 'Could not find value for stratification'
      },
      {
        'factory_name' => :expected_results_validator_generate_does_not_match_population_error_message,
        'report_text' => 'Expected IPP value'
      }
    ],
    'ExpectedSupplementalResults' => [
      {
        'factory_name' => :expected_supplemental_results_check_supplemental_data_matches_pop_sums,
        'report_text' => 'Reported IPP value'
      },
      {
        'factory_name' => :expected_supplemental_results_add_sup_data_error,
        'report_text' => '1002-5'
      }
    ],
    'MeasurePeriodValidator' => [
      {
        'factory_name' => :measure_period_validator_validate_start,
        'report_text' => 'Reported Measurement Period'
      }
    ],
    'ProgramCriteriaValidator' => [
      {
        'factory_name' => :program_criteria_validator_patient_has_pcp_and_other_element,
        'report_text' => 'contain at least one Patient Characteristic Payer template'
      }
    ],
    'ProgramValidator' => [
      {
        'factory_name' => :program_validator_validate,
        'report_text' => 'Expected to find program'
      }
    ],
    'ProviderTypeValidator' => [
      {
        'factory_name' => :provider_type_validator_validate,
        'report_text' => 'Provider specialties'
      }
    ],
    'QrdaCat1Validator' => [
      {
        'factory_name' => :qrda_cat1_validator_cat1_r5,
        'report_text' => 'CONF:3343'
      },
      {
        'factory_name' => :qrda_cat1_validator_qrda_qdm_template_validator,
        'report_text' => 'are not valid Patient Data Section QDM entries'
      },
      {
        'factory_name' => :qrda_cat1_validator_validate_measures,
        'report_text' => 'Document does not state it is reporting measure'
      }
    ],
    'QrdaCat3Validator' => [
      {
        'factory_name' => :qrda_cat3_validator_cat3_performance_rate,
        'report_text' => 'Reported Performance Rate'
      },
      {
        'factory_name' => :qrda_cat3_validator_cat3_measure,
        'report_text' => 'Invalid HQMF Set ID'
      },
      {
        'factory_name' => :qrda_cat3_validator_cat3_r21,
        'report_text' => 'CONF'
      },
      {
        'factory_name' => :qrda_cat3_validator_cda,
        'report_text' => 'urn:hl7-org:v3'
      }
    ],
    'SmokingGunValidator' => [
      {
        'factory_name' => :smoking_gun_validator_errors,
        'report_text' => 'not found in archive as expected'
      },
      {
        'factory_name' => :smoking_gun_validator_validate_name,
        'report_text' => 'not found in test records'
      },
      {
        'factory_name' => :smoking_gun_validator_validate_expected_results,
        'report_text' => 'not expected to be returned'
      }
    ],
    'TestExecution' => [
      {
        'factory_name' => :test_execution_conditionally_add_task_specific_errors,
        'report_text' => '4 files expected but was 1'
      }
    ]
  }.freeze

  test 'should generate a report' do
    # Iterate through each validator
    random = Random.new
    TEST_EXECUTION_ERROR_HASH.each_value do |sample_errors|
      # Iterate through each sample_error for validator
      sample_errors.each do |sample_error_hash|
        # test file will be the generated report
        testfile = Tempfile.new(['report', '.zip'])
        # create a test execution to assign the error message to. We're just using C2 test execution or all errors
        te = @product_test.tasks.c2_task.test_executions.build(state: :failed, user: @user)
        ste = @product_test.tasks.c3_cat3_task.test_executions.build(state: :failed, user: @user, sibling_execution_id: te.id.to_s)
        te.sibling_execution_id = ste.id.to_s
        # add error message
        if random.rand(2).zero?
          build_execution_error(te, sample_error_hash['factory_name'], ste)
          check_error_collector(te)
        else
          build_execution_error(ste, sample_error_hash['factory_name'], te)
          check_error_collector(ste)
        end
        te.save
        ste.save
        # Use product controller to generate report
        @controller = ProductsController.new
        for_each_logged_in_user([ATL]) do
          get :report, params: { format: :format_does_not_matter, vendor_id: @vendor.id, id: @first_product.id }
          testfile.write response.body
        end
        # Open zipfile to find report
        Zip::File.open(testfile.path, Zip::File::CREATE) do |zip|
          report_html = Nokogiri::HTML.parse(zip.read('product_report.html'))
          # Un-comment line below to print out the report (for easier debugging)
          # File.write("script/report_#{sample_error_hash['factory_name']}.html", report_html)
          # search product_report to find 'report_text'.  This will assert that the report included the error message
          assert report_html.at("ul:contains('#{sample_error_hash['report_text']}')"), "error with factory #{sample_error_hash['factory_name']}"
        end
        # Clean up
        testfile.unlink
        te.execution_errors.destroy
        ste.execution_errors.destroy
      end
    end
  end

  def check_error_collector(test_execution)
    return unless test_execution.execution_errors.first.validator_type

    collected_errors = collected_errors(test_execution)
    error_count = collected_errors[:nonfile].size
    collected_errors[:files].each_value do |collected_error_values|
      error_count += collected_error_values['Errors'][:execution_errors].size
      error_count += collected_error_values['Warnings'][:execution_errors].size
    end
    assert_equal error_count, test_execution.execution_errors.size
  end

  def build_execution_error(test_execution, factory_name, sibling_execution)
    # A test execution needs an artifact, since we are always using a C2 test execution, create a Cat 3 artifact
    file_name = 'cat_III/ep_test_qrda_cat3_good.xml'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', file_name))
    Artifact.create!(test_execution: test_execution, file: file)
    Artifact.create!(test_execution: sibling_execution, file: file)
    sibling_execution.state = :passed
    FactoryBot.create(factory_name, test_execution: test_execution, file_name: file_name.split('/')[1])
  end
end
