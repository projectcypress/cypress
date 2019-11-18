require 'test_helper'

class ProductReportTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  setup do
    @user = FactoryBot.create(:atl_user)
    @product_test = FactoryBot.create(:cv_product_test_static_result)
    @first_product = @product_test.product
    @product_test.tasks.create({}, C1Task)
    @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.tasks.create({}, C3Cat1Task)
    @product_test.tasks.create({}, C3Cat3Task)
    @product_test.save
    @vendor = @product_test.product.vendor
  end

  # Key is the Class the error is reported from
  # 'method' is the method in the class that creates the error
  # 'report_text' is a subset of the error message that we will use to determine if it exists in the product report
  # 'execution_error' is a hash created from generating the specific error in a real Cypress test.
  TEST_EXECUTION_ERROR_HASH = {
    'CalculatingSmokingGunValidator' => [
      {
        'method' => 'compare_results',
        'report_text' => 'does not match expected value',
        'execution_error' => {
          'message' => 'Calculated value (0) for IPP (78A9F833-07AA-448F-B94F-B2C4D8BF4F3F) does not match expected value (1)',
          'msg_type' => 'error',
          'validator_type' => 'result_validation',
          'validator' => 'Validators::CalculatingSmokingGunValidator',
          'cms' => false
        }
      }
    ],
    'Cat3PopulationValidator' => [
      {
        'method' => 'validate_populations',
        'report_text' => 'greater than Initial Population',
        'execution_error' => {
          'message' => 'Denominator value 2 is greater than Initial Population value 0 for measure d9c50230-f1c5-0137-ffa9-2cde48001122',
          'msg_type' => 'error',
          'validator' => 'Validators::Cat3PopulationValidator',
          'validator_type' => 'result_validation',
          'location' => '/',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => true
        }
      }
    ],
    'ChecklistTest' => [
      {
        'method' => 'build_execution_errors_for_incomplete_checked_criteria',
        'report_text' => 'CMS159v8 - patient_characteristic, expired not complete',
        'execution_error' => {
          'message' => 'CMS159v8 - patient_characteristic, expired not complete',
          'msg_type' => 'error',
          'validator' => 'qrda_cat1',
          'cms' => false
        }
      }
    ],
    'CMSPopulationCountValidator' => [
      {
        'method' => 'verify_all_codes_reported',
        'report_text' => 'all PAYER codes present',
        'execution_error' => {
          'message' => 'For CMS eligible clinicians and eligible professionals programs, all PAYER codes present in the value set must be reported,even if the count is zero. If an eCQM is episode-based, the count will reflect the patient count rather than the episode count.',
          'msg_type' => 'error',
          'validator' => 'Validators::CMSPopulationCountValidator',
          'validator_type' => 'result_validation',
          'cms' => false
        }

      }
    ],
    'CMSProgramTest' => [
      {
        'method' => 'build_execution_errors_for_incomplete_cms_criteria',
        'report_text' => 'Tax Identification Number not complete',
        'execution_error' => {
          'message' => 'Tax Identification Number not complete',
          'msg_type' => 'error',
          'validator' => 'Validators::ProgramCriteriaValidator',
          'cms' => false
        }

      }
    ],
    'CMSSchematronValidator' => [
      {
        'method' => 'validate',
        'report_text' => 'CONF:CMS_3',
        'execution_error' => {
          'message' => 'SHALL contain exactly one [1..1] templateId (CONF:CMS_1) such that it SHALL contain exactly one [1..1] @root=\"2.16.840.1.113883.10.20.27.1.2\" (CONF:CMS_2).SHALL contain exactly one [1..1] @extension=\"2019-05-01\" (CONF:CMS_3).',
          'msg_type' => 'error',
          'validator' => 'Validators::CMSQRDA3SchematronValidator',
          'validator_type' => 'xml_validation',
          'location' => '/*/*[19]/*/*[3]/*/*[8]/*/*[3]/*/*[7]',
          'file_name' => 'CMS111v8_5dd549f2c1c388f14a018d9b.debug.xml',
          'cms' => false
        }

      }
    ],
    'EHRCertificationIdValidator' => [
      {
        'method' => 'validate',
        'report_text' => 'CMS EHR Certification ID',
        'execution_error' => {
          'message' => 'CMS EHR Certification ID is required if Promoting Interoperability performance category (Promoting Interoperability Section (V2) identifier: urn:hl7ii:2.16.840.1.113883.10.20.27.2.5:2017-06-01) is present in a QRDA III document. If CMS EHR Certification ID is not supplied, the score for the PI performance category will be 0.',
          'msg_type' => 'error',
          'validator' => 'Validators::EHRCertificationIdValidator',
          'validator_type' => 'result_validation',
          'cms' => false
        }

      }
    ],
    'EncounterValidator' => [
      {
        'method' => 'validate_encounter_start_end',
        'report_text' => 'before start time',
        'execution_error' => {
          'message' => 'Encounter ends (4/23/2018 18:15) before start time (4/24/2018 17:00)',
          'msg_type' => 'error',
          'validator' => 'Validators::EncounterValidator',
          'validator_type' => 'result_validation',
          'location' => '/*/*[19]/*/*[3]/*/*[8]/*/*[3]/*/*[7]',
          'file_name' => 'CMS111v8_5dd549f2c1c388f14a018d9b.debug.xml',
          'cms' => false
        }
      },
      {
        'method' => 'get_time_value',
        'report_text' => 'CMS_0075',
        'execution_error' => {
          'message' => 'CMS_0075 - Fails validation check for Encounter Performed Admission Date (effectiveTime/low value)\n            as specified in Table 14: Valid Date/Time Format for HQR.',
          'msg_type' => 'error',
          'validator' => 'Validators::EncounterValidator',
          'validator_type' => 'result_validation',
          'location' => '/*/*[19]/*/*[3]/*/*[8]/*/*[3]/*/*[7]',
          'file_name' => 'CMS111v8_5dd549f2c1c388f14a018d9b.debug.xml',
          'cms' => false
        }
      }
    ],
    'ExpectedResultsValidator' => [
      {
        'method' => 'generate_could_not_find_population_error_message',
        'report_text' => 'Could not find value for Population IPP',
        'execution_error' => {
          'message' => 'Could not find value for Population IPP',
          'msg_type' => 'error',
          'validator' => 'Validators::ExpectedResultsValidator',
          'validator_type' => 'result_validation',
          'location' => '/',
          'measure_id' => '40280382-68D3-A5FE-0169-06FF09260E87',
          'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
          'stratification' => nil,
          'cms' => false
        }
      },
      {
        'method' => 'generate_could_not_find_population_error_message',
        'report_text' => 'Could not find value for stratification',
        'execution_error' => {
          'message' => 'Could not find value for stratification 30D23C7A-7947-4E36-B127-4AD51C371202  for Population IPP',
          'msg_type' => 'error',
          'validator' => 'Validators::ExpectedResultsValidator',
          'validator_type' => 'result_validation',
          'location' => '/',
          'measure_id' => '40280382-68D3-A5FE-0169-06FF09260E87',
          'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
          'stratification' => '30D23C7A-7947-4E36-B127-4AD51C371202',
          'cms' => false
        }
      },
      {
        'method' => 'generate_does_not_match_population_error_message',
        'report_text' => 'Expected IPP value',
        'execution_error' => {
          'message' => 'Expected IPP value 4\n      does not match reported value 3',
          'msg_type' => 'error',
          'validator' => 'Validators::ExpectedResultsValidator',
          'validator_type' => 'result_validation',
          'location' => '/',
          'measure_id' => '40280382-68D3-A5FE-0169-06FF09260E87',
          'error_details' => {
            'type' => 'population',
            'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
            'stratification' => nil,
            'expected_value' => 4,
            'reported_value' => 3
          },
          'file_name' => 'CMS111v8_5dd549f2c1c388f14a018d9b.debug.xml',
          'cms' => false
        }
      }
    ],
    'ExpectedSupplementalResults' => [
      {
        'method' => 'check_supplemental_data_matches_pop_sums',
        'report_text' => 'Reported IPP value',
        'execution_error' => {
          'message' => 'Reported IPP value 4 does not match sum 5 of supplemental key RACE values',
          'msg_type' => 'error',
          'validator' => 'Validators::ExpectedSupplementalResults',
          'validator_type' => 'result_validation',
          'location' => '/',
          'measure_id' => '40280382-68D3-A5FE-0169-06FF09260E87',
          'error_details' => {
            'type' => 'population_sum',
            'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
            'stratification' => nil,
            'expected_value' => 4,
            'reported_value' => 5
          },
          'file_name' => 'CMS111v8_5dd549f2c1c388f14a018d9b.debug.xml',
          'cms' => false
        }
      },
      {
        'method' => 'add_sup_data_error',
        'report_text' => '1002-5',
        'execution_error' => {
          'message' => 'supplemental data error',
          'msg_type' => 'error',
          'validator' => 'Validators::ExpectedSupplementalResults',
          'validator_type' => :result_validation,
          'location' => '/',
          'measure_id' => '440280382-68D3-A5FE-0169-06FF09260E87',
          'error_details' => {
            'type' => 'supplemental_data',
            'population_key' => 'IPP',
            'data_type' => 'RACE',
            'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
            'code' => '1002-5',
            'expected_value' => 1,
            'reported_value' => 0
          },
          'file_name' => '18_etech-qrda-cat3-11-14-2019-10-19-14.xml',
          'cms' => false
        }
      }
    ],
    'MeasurePeriodValidator' => [
      {
        'method' => 'validate_start',
        'report_text' => 'Reported Measurement Period',
        'execution_error' => {
          'message' => 'Reported Measurement Period should start on 20180101',
          'msg_type' => 'error',
          'validator' => 'Validators::MeasurePeriodValidator',
          'validator_type' => 'submission_validation',
          'location' => '/',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => true
        }
      }
    ],
    'ProgramCriteriaValidator' => [
      {
        'method' => 'patient_has_pcp_and_other_element',
        'report_text' => 'contain at least one Patient Characteristic Payer template',
        'execution_error' => {
          'message' => 'The Patient Data Section QDM (V6) - CMS shall contain at least one Patient Characteristic Payer template and at least one entry template that is other than the Patient Characteristic Payer template.',
          'msg_type' => 'error',
          'validator' => 'Validators::ProgramCriteriaValidator',
          'validator_type' => 'xml_validation',
          'cms' => false
        }

      }
    ],
    'ProgramValidator' => [
      {
        'method' => 'patient_has_pcp_and_other_element',
        'report_text' => 'Expected to find program',
        'execution_error' => {
          'message' => "Expected to find program 'HQR_PI' but no program code was found.",
          'msg_type' => 'error',
          'validator' => 'Validators::ProgramValidator',
          'validator_type' => 'result_validation',
          'cms' => false
        }

      }
    ],
    'ProviderTypeValidator' => [
      {
        'method' => 'validate',
        'report_text' => 'Provider specialties',
        'execution_error' => {
          'message' => 'Provider specialties () do not match expected value (282N00000X)',
          'msg_type' => 'error',
          'validator' => 'Validators::ProviderTypeValidator',
          'validator_type' => 'result_validation',
          'cms' => false
        }

      }
    ],
    'QrdaCat1Validator' => [
      {
        'method' => 'Cat1R5',
        'report_text' => 'CONF:3343',
        'execution_error' => {
          'message' => 'This template SHALL be contained by an Encounter Performed Act (V2) (CONF:3343-28803).',
          'msg_type' => 'error',
          'validator' => 'CqmValidators::Cat1R5',
          'validator_type' => 'xml_validation',
          'location' => '/*/*[19]/*/*[3]/*/*[9]',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => false
        }
      },
      {
        'method' => 'QrdaQdmTemplateValidator',
        'report_text' => 'are not valid Patient Data Section QDM entries',
        'execution_error' => {
          'message' => '[\"2.16.840.1.113883.10.20.24.3.133:2016-08-01\"] are not valid Patient Data Section QDM entries for this QRDA Version',
          'msg_type' => 'warning',
          'validator' => 'CqmValidators::QrdaQdmTemplateValidator',
          'validator_type' => 'xml_validation',
          'location' => '/*/*[19]/*/*[3]/*/*[9]',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => false
        }
      },
      {
        'method' => 'validate_measures',
        'report_text' => 'Document does not state it is reporting measure',
        'execution_error' => {
          'message' => 'Document does not state it is reporting measure 40280382-68D3-A5FE-0169-06FF09260E87  - Median time (in minutes) from admit decision time to time of departure from the emergency department for emergency department patients admitted to inpatient status',
          'msg_type' => 'error',
          'validator' => 'Validators::QrdaCat1Validator',
          'validator_type' => 'xml_validation',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => false
        }
      }
    ],
    'QrdaCat3Validator' => [
      {
        'method' => 'Cat3PerformanceRate',
        'report_text' => 'Reported Performance Rate',
        'execution_error' => {
          'message' => 'Reported Performance Rate of 0.5 for Numerator A5976BE6-7F1C-419D-898D-7AFEB141A355 does not match expected value of 0.6.',
          'msg_type' => 'error',
          'validator' => 'CqmValidators::Cat3PerformanceRate',
          'validator_type' => 'xml_validation',
          'location' => '/',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => false
        }
      },
      {
        'method' => 'Cat3Measure',
        'report_text' => 'Invalid HQMF Set ID',
        'execution_error' => {
          'message' => 'Invalid HQMF Set ID Found: 8455CD3E-DBB9-4E0C-8084-3ECE4068FE95',
          'msg_type' => 'error',
          'validator' => 'CqmValidators::Cat3Measure',
          'validator_type' => 'xml_validation',
          'location' => '/',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => false
        }
      },
      {
        'method' => 'Cat3R21',
        'report_text' => 'CONF',
        'execution_error' => {
          'message' => 'This confidentialityCode SHALL contain exactly one [1..1] @code=\"N\" Normal (CodeSystem=> HL7Confidentiality urn=>oid=>2.16.840.1.113883.5.25) (CONF:CMS_4).',
          'msg_type' => 'error',
          'validator' => 'Validators::CMSQRDA3SchematronValidator',
          'validator_type' => 'xml_validation',
          'location' => "/*[local-name()='ClinicalDocument' and namespace-uri()='urn=>hl7-org=>v3']/*[local-name()='confidentialityCode' and namespace-uri()='urn=>hl7-org=>v3']",
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => true
        }
      },
      {
        'method' => 'CDA',
        'report_text' => 'urn:hl7-org:v3',
        'execution_error' => {
          'message' => "10:0: ERROR: Element '{urn:hl7-org:v3}templateId': This element is not expected. Expected is ( {urn:hl7-org:v3}code ).",
          'msg_type' => 'error',
          'validator' => 'CqmValidators::CDA',
          'validator_type' => 'xml_validation',
          'location' => '/',
          'file_name' => '_5dd80db0c1c3880a07f2c0ce.debug.xml',
          'cms' => true
        }
      }
    ],
    'SmokingGunValidator' => [
      {
        'method' => 'errors',
        'report_text' => 'not found in archive as expected',
        'execution_error' => {
          'message' => 'Records for patients GREG ESTRADA, ADRIAN NORTON, SHEILA FORD not found in archive as expected',
          'msg_type' => 'error',
          'validator_type' => 'result_validation',
          'cms' => false
        }
      },
      {
        'method' => 'validate_name',
        'report_text' => 'not found in test records',
        'execution_error' => {
          'message' => "Patient name 'BRYAN SUMMERS' declared in file not found in test records",
          'msg_type' => 'error',
          'validator' => 'Validators::CalculatingSmokingGunValidator',
          'validator_type' => 'result_validation',
          'cms' => false
        }
      },
      {
        'method' => 'validate_expected_results',
        'report_text' => 'not expected to be returned',
        'execution_error' => {
          'message' => "Patient 'APRIL WELCH' not expected to be returned.",
          'msg_type' => 'error',
          'validator' => 'Validators::CalculatingSmokingGunValidator',
          'validator_type' => 'result_validation',
          'cms' => false
        }
      }
    ],
    'TestExecution' => [
      {
        'method' => 'conditionally_add_task_specific_errors',
        'report_text' => '4 files expected but was 1',
        'execution_error' => {
          'message' => '4 files expected but was 1"',
          'msg_type' => 'error',
          'validator_type' => 'result_validation',
          'validator' => 'smoking_gun',
          'cms' => false
        }
      }
    ]
  }.freeze

  test 'should generate a report' do
    # Iterate through each validator
    TEST_EXECUTION_ERROR_HASH.each do |validator, sample_errors|
      # Iterate through each sample_error for validator
      sample_errors.each do |sample_error_hash|
        # test file will be the generated report
        testfile = Tempfile.new(['report', '.zip'])
        # create a test execution to assign the error message to. We're just using C2 test execution or all errors
        te = @product_test.tasks.c2_task.test_executions.build(state: :failed, user: @user)
        # add error message
        build_execution_error(te, sample_error_hash['execution_error'])
        te.save
        # Use product controller to generate report
        @controller = ProductsController.new
        for_each_logged_in_user([ATL]) do
          get :report, params: { format: :format_does_not_matter, vendor_id: @vendor.id, id: @first_product.id }
          testfile.write response.body
        end
        # Open zipfile to find report
        Zip::File.open(testfile.path, Zip::File::CREATE) do |zip|
          report_html = Nokogiri::HTML.parse(zip.read('product_report.html'))
          # search product_report to find 'report_text'.  This will assert that the report included the error message
          assert report_html.at("ul:contains('#{sample_error_hash['report_text']}')"), "error with #{validator} in method #{sample_error_hash['method']}"
        end
        # Clean up
        testfile.unlink
        te.execution_errors.destroy
      end
    end
  end

  def build_execution_error(test_execution, execution_error)
    # A test execution needs an artifact, since we are always using a C2 test execution, create a Cat 3 artifact
    file_name = 'cat_III/ep_test_qrda_cat3_good.xml'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', file_name))
    Artifact.create!(test_execution: test_execution, file: file)
    test_execution.execution_errors.build(message: execution_error['message'],
                                          msg_type: execution_error['msg_type'],
                                          measure_id: execution_error['measure_id'],
                                          validator_type: execution_error['validator_type'],
                                          validator: execution_error['validator'],
                                          stratification: execution_error['stratification'],
                                          location: execution_error['location'],
                                          file_name: file_name.split('/')[1],
                                          cms: execution_error['msg_type'])
    # error details is not actually part of the execution_error model, add it after
    test_execution.execution_errors[0]['error_details'] = execution_error['error_details']
  end
end
