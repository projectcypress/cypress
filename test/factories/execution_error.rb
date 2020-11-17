FactoryBot.define do
  factory :execution_error, class: ExecutionError do
    test_execution

    after(:build) do |ee|
      ee[:validator_type] = ee.validation_type&.to_sym
    end

    factory :calculating_smoking_gun_validator do
      msg_type { 'error' }
      validation_type { 'result_validation' }
      validator { 'Validators::CalculatingSmokingGunValidator' }
      cms { false }

      trait :compare_results do
        message { 'Calculated value (0) for IPP (78A9F833-07AA-448F-B94F-B2C4D8BF4F3F) does not match expected value (1)' }
      end

      trait :qrda_import_warning do
        msg_type { 'warning' }
        message { 'Interval with nullFlavor low time and nullFlavor high time' }
      end

      factory :calculating_smoking_gun_validator_compare_results, traits: [:compare_results]
      factory :calculating_smoking_gun_validator_qrda_import_warning, traits: [:qrda_import_warning]
    end

    factory :cat3_population_validator do
      msg_type { 'error' }
      validator { 'Validators::Cat3PopulationValidator' }
      validation_type { 'result_validation' }
      location { '/' }
      cms { false }

      trait :validate_populations do
        message { 'Denominator value 2 is greater than Initial Population value 0 for measure d9c50230-f1c5-0137-ffa9-2cde48001122' }
      end

      factory :cat3_population_validator_validate_populations, traits: [:validate_populations]
    end

    factory :cms_population_count_validator do
      msg_type { 'error' }
      validator { 'Validators::CMSPopulationCountValidator' }
      validation_type { 'result_validation' }
      cms { false }

      trait :verify_all_codes_reported do
        message { 'For CMS eligible clinicians and eligible professionals programs, all PAYER codes present in the value set must be reported,even if the count is zero. If an eCQM is episode-based, the count will reflect the patient count rather than the episode count.' }
      end

      factory :cms_population_count_validator_verify_all_codes_reported, traits: [:verify_all_codes_reported]
    end

    factory :cms_schematron_validator do
      msg_type { 'error' }
      validator { 'Validators::CMSQRDA3SchematronValidator' }
      validation_type { 'xml_validation' }
      location { '/*/*[19]/*/*[3]/*/*[8]/*/*[3]/*/*[7]' }
      cms { false }

      trait :validate do
        message { 'SHALL contain exactly one [1..1] templateId (CONF:CMS_1) such that it SHALL contain exactly one [1..1] @root=\"2.16.840.1.113883.10.20.27.1.2\" (CONF:CMS_2).SHALL contain exactly one [1..1] @extension=\"2019-05-01\" (CONF:CMS_3).' }
      end

      factory :cms_schematron_validator_validate, traits: [:validate]
    end

    factory :ehr_certification_id_validator do
      msg_type { 'error' }
      validator { 'Validators::EHRCertificationIdValidator' }
      validation_type { 'result_validation' }
      cms { false }

      trait :validate do
        message { 'CMS EHR Certification ID is required if Promoting Interoperability performance category (Promoting Interoperability Section (V2) identifier: urn:hl7ii:2.16.840.1.113883.10.20.27.2.5:2017-06-01) is present in a QRDA III document. If CMS EHR Certification ID is not supplied, the score for the PI performance category will be 0.' }
      end

      factory :ehr_certification_id_validator_validate, traits: [:validate]
    end

    factory :encounter_validator do
      msg_type { 'error' }
      validator { 'Validators::EncounterValidator' }
      validation_type { 'result_validation' }
      location { '/*/*[19]/*/*[3]/*/*[8]/*/*[3]/*/*[7]' }
      cms { false }

      trait :validate_encounter_start_end do
        message { 'Encounter ends (4/23/2018 18:15) before start time (4/24/2018 17:00)' }
      end

      trait :get_time_value do
        message { 'CMS_0075 - Fails validation check for Encounter Performed Admission Date (effectiveTime/low value)\n            as specified in Table 14: Valid Date/Time Format for HQR.' }
      end

      factory :encounter_validator_validate_encounter_start_end, traits: [:validate_encounter_start_end]
      factory :encounter_validator_get_time_value, traits: [:get_time_value]
    end

    factory :expected_results_validator do
      msg_type { 'error' }
      validator { 'Validators::ExpectedResultsValidator' }
      validation_type { 'result_validation' }
      measure_id { '40280382-68D3-A5FE-0169-06FF09260E87' }
      location { '/' }
      cms { false }

      trait :generate_could_not_find_population_error_message do
        message { 'Could not find value for Population IPP' }
        after(:build) do |ee|
          ee[:population_id] = '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F'
        end
      end

      trait :generate_could_not_find_population_stratification_error_message do
        stratification { '30D23C7A-7947-4E36-B127-4AD51C371202' }
        message { 'Could not find value for stratification 30D23C7A-7947-4E36-B127-4AD51C371202  for Population IPP' }
        after(:build) do |ee|
          ee[:population_id] = '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F'
        end
      end

      trait :generate_does_not_match_population_error_message do
        message { 'Expected IPP value 4\n      does not match reported value 3' }
        after(:build) do |ee|
          ee[:error_details] = { 'type' => 'population',
                                 'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
                                 'stratification' => nil,
                                 'expected_value' => 4,
                                 'reported_value' => 3 }
        end
      end

      factory :expected_results_validator_generate_could_not_find_population_error_message, traits: [:generate_could_not_find_population_error_message]
      factory :expected_results_validator_generate_could_not_find_population_stratification_error_message, traits: [:generate_could_not_find_population_stratification_error_message]
      factory :expected_results_validator_generate_does_not_match_population_error_message, traits: [:generate_does_not_match_population_error_message]
    end

    factory :expected_supplemental_results do
      msg_type { 'error' }
      validator { 'Validators::ExpectedSupplementalResults' }
      validation_type { :result_validation }
      measure_id { '40280382-68D3-A5FE-0169-06FF09260E87' }
      location { '/' }
      cms { false }

      trait :check_supplemental_data_matches_pop_sums do
        message { 'Reported IPP value 4 does not match sum 5 of supplemental key RACE values' }
        after(:build) do |ee|
          ee[:error_details] = { 'type' => 'population_sum',
                                 'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
                                 'stratification' => nil,
                                 'expected_value' => 4,
                                 'reported_value' => 5 }
        end
      end

      trait :add_sup_data_error do
        message { 'supplemental data error' }
        measure_id { '440280382-68D3-A5FE-0169-06FF09260E87' }
        after(:build) do |ee|
          ee[:error_details] = { 'type' => 'supplemental_data',
                                 'population_key' => 'IPP',
                                 'data_type' => 'RACE',
                                 'population_id' => '78A9F833-07AA-448F-B94F-B2C4D8BF4F3F',
                                 'code' => '1002-5',
                                 'expected_value' => 1,
                                 'reported_value' => 0 }
        end
      end

      after(:build) do |ee|
        ee[:validator_type] = :result_validation
      end

      factory :expected_supplemental_results_check_supplemental_data_matches_pop_sums, traits: [:check_supplemental_data_matches_pop_sums]
      factory :expected_supplemental_results_add_sup_data_error, traits: [:add_sup_data_error]
    end

    factory :measure_period_validator do
      msg_type { 'error' }
      validator { 'Validators::MeasurePeriodValidator' }
      validation_type { 'submission_validation' }
      location { '/' }
      cms { false }

      trait :validate_start do
        message { 'Reported Measurement Period should start on 20180101' }
      end

      factory :measure_period_validator_validate_start, traits: [:validate_start]
    end

    factory :program_criteria_validator do
      msg_type { 'error' }
      validator { 'Validators::ProgramCriteriaValidator' }
      validation_type { 'xml_validation' }
      location { '/' }
      cms { false }

      trait :patient_has_pcp_and_other_element do
        message { 'The Patient Data Section QDM (V6) - CMS shall contain at least one Patient Characteristic Payer template and at least one entry template that is other than the Patient Characteristic Payer template.' }
      end

      factory :program_criteria_validator_patient_has_pcp_and_other_element, traits: [:patient_has_pcp_and_other_element]
    end

    factory :program_validator do
      msg_type { 'error' }
      validator { 'Validators::ProgramValidator' }
      validation_type { 'result_validation' }
      cms { false }

      trait :validate do
        message { "Expected to find program 'HQR_PI' but no program code was found." }
      end

      factory :program_validator_validate, traits: [:validate]
    end

    factory :provider_type_validator do
      msg_type { 'error' }
      validator { 'Validators::ProviderTypeValidator' }
      validation_type { 'result_validation' }
      cms { false }

      trait :validate do
        message { 'Provider specialties () do not match expected value (282N00000X)' }
      end

      factory :provider_type_validator_validate, traits: [:validate]
    end

    factory :qrda_cat1_validator do
      validation_type { 'xml_validation' }
      cms { false }

      trait :cat1_r5 do
        msg_type { 'error' }
        validator { 'CqmValidators::Cat1R5' }
        message { 'This template SHALL be contained by an Encounter Performed Act (V2) (CONF:3343-28803).' }
        location { '/*/*[19]/*/*[3]/*/*[8]/*/*[3]/*/*[7]' }
      end

      trait :qrda_qdm_template_validator do
        msg_type { 'warning' }
        validator { 'CqmValidators::QrdaQdmTemplateValidator' }
        message { '[\"2.16.840.1.113883.10.20.24.3.133:2016-08-01\"] are not valid Patient Data Section QDM entries for this QRDA Version' }
        location { '/*/*[19]/*/*[3]/*/*[9]' }
      end

      trait :validate_measures do
        msg_type { 'error' }
        validator { 'Validators::QrdaCat1Validator' }
        message { 'Document does not state it is reporting measure 40280382-68D3-A5FE-0169-06FF09260E87  - Median time (in minutes) from admit decision time to time of departure from the emergency department for emergency department patients admitted to inpatient status' }
        location { '/*/*[19]/*/*[3]/*/*[9]' }
      end

      factory :qrda_cat1_validator_cat1_r5, traits: [:cat1_r5]
      factory :qrda_cat1_validator_qrda_qdm_template_validator, traits: [:qrda_qdm_template_validator]
      factory :qrda_cat1_validator_validate_measures, traits: [:validate_measures]
    end

    factory :qrda_cat3_validator do
      validation_type { 'xml_validation' }
      msg_type { 'error' }
      location { '/' }

      trait :cat3_performance_rate do
        validator { 'CqmValidators::Cat3PerformanceRate' }
        message { 'Reported Performance Rate of 0.5 for Numerator A5976BE6-7F1C-419D-898D-7AFEB141A355 does not match expected value of 0.6.' }
        cms { false }
      end

      trait :cat3_measure do
        validator { 'CqmValidators::Cat3Measure' }
        message { 'Invalid HQMF Set ID Found: 8455CD3E-DBB9-4E0C-8084-3ECE4068FE95' }
        cms { false }
      end

      trait :cat3_r21 do
        validator { 'Validators::CMSQRDA3SchematronValidator' }
        message { 'This confidentialityCode SHALL contain exactly one [1..1] @code=\"N\" Normal (CodeSystem=> HL7Confidentiality urn=>oid=>2.16.840.1.113883.5.25) (CONF:CMS_4).' }
        cms { true }
      end

      trait :cda do
        validator { 'CqmValidators::CDA' }
        message { "10:0: ERROR: Element '{urn:hl7-org:v3}templateId': This element is not expected. Expected is ( {urn:hl7-org:v3}code )." }
        cms { true }
      end

      factory :qrda_cat3_validator_cat3_performance_rate, traits: [:cat3_performance_rate]
      factory :qrda_cat3_validator_cat3_measure, traits: [:cat3_measure]
      factory :qrda_cat3_validator_cat3_r21, traits: [:cat3_r21]
      factory :qrda_cat3_validator_cda, traits: [:cda]
    end

    factory :smoking_gun_validator do
      msg_type { 'error' }
      validation_type { 'xml_validation' }
      cms { false }

      trait :errors do
        message { 'Records for patients GREG ESTRADA, ADRIAN NORTON, SHEILA FORD not found in archive as expected' }
      end

      trait :validate_name do
        validator { 'Validators::CalculatingSmokingGunValidator' }
        message { "Patient name 'BRYAN SUMMERS' declared in file not found in test records" }
      end

      trait :validate_expected_results do
        validator { 'Validators::CalculatingSmokingGunValidator' }
        message { "Patient 'APRIL WELCH' not expected to be returned." }
      end

      factory :smoking_gun_validator_errors, traits: [:errors]
      factory :smoking_gun_validator_validate_name, traits: [:validate_name]
      factory :smoking_gun_validator_validate_expected_results, traits: [:validate_expected_results]
    end
  end
end
