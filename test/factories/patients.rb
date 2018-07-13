# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient, class: Patient do
    sequence(:familyName) { |i| "Patient Name #{i}" }
    sequence(:givenNames) { |n| [n.to_s] }
    qdmVersion '5.3'
    birthDatetime 1_340_323_200
    extended_data_value = {
      'medical_record_assigner' => 'Bonnie',
      'notes' => "70yo female; DExcl 56,90 Num 127,130 DExcep 139,149\n*17qdes\n*Pt w h/o advancing dementia and heart failure. Suffered multiple fractures requiring surgery and occ therapy.",
      'insurance_providers' => '[{"codes":{"SOP":["349"]},"name":"Other","type":"OT","payer":{"name":"Other"},"financial_responsibility_type":{"code":"SELF","codeSystem":"HL7 Relationship Code"},"member_id":"1374589940","start_time":"1949-05-23T13:24:00+00:00"}]'
    }
    sequence(:extendedData) do |i|
      {
        'medical_record_number' => "#{i}989db70-4d42-0135-8680-20999b0ed66f"
      }.merge(extended_data_value)
    end
    data_elements_value = [
      {
        'authorDatetime' => '2012-09-28T08:00:00.000+00:00',
        'category' => 'procedure',
        'components' => [],
        'dataElementCodes' => [
          {
            'codeSystem' => 'SNOMED-CT',
            'code' => '210'
          },
          {
            'codeSystem' => 'CPT',
            'code' => '60'
          }
        ],
        'description' => 'Procedure, Performed: Pneumococcal Vaccine Administered',
        'hqmfOid' => '2.16.840.1.113883.3.560.1.6',
        'qdmStatus' => 'performed',
        'qdmVersion' => '5.3',
        'relevantPeriod' => {
          'low' => '2012-09-28T08:00:00+00:00',
          'high' => '2012-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        },
        '_type' => 'QDM::ProcedurePerformed'
      },
      {
        'dataElementCodes' => [ 
          {
              'codeSystem' => 'SNOMED-CT',
              'code' => '24'
          }
        ],
        '_type' => 'QDM::Diagnosis',
        'hqmfOid' => '2.16.840.1.113883.3.560.1.2',
        'qrdaOid' => '2.16.840.1.113883.10.20.24.3.135',
        'category' => 'condition',
        'qdmVersion' => '5.3',
        'description' => 'Diagnosis: Allergy to Eggs',
        'prevalencePeriod' => {
          'low' => '2012-09-28T08:00:00+00:00',
          'high' => '2012-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        },
      },
      {
        'category' => 'patient_characteristic',
        'dataElementCodes' => [
          {
            'code' => 'F',
            'codeSystem' => 'AdministrativeGender',
            'descriptor' => 'F',
            'codeSystemOid' => '2.16.840.1.113883.5.1'
          }
        ],
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.55',
        'description' => nil,
        'qdmStatus' => 'gender',
        'qdmVersion' => '5.3',
        '_type' => 'QDM::PatientCharacteristicSex'
      },
      {
        'dataElementCodes' => [
          {
            'code' => '21112-8',
            'codeSystem' => 'LOINC'
          }
        ],
        '_type' => 'QDM::PatientCharacteristicBirthdate',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.54',
        'description' => nil,
        'category' => 'patient_characteristic',
        'qdmStatus' => 'birthdate',
        'qdmVersion' => '5.3',
        'birthDatetime' => '1947-08-01T00:00:00+00:00'
      },
      {
        'dataElementCodes' => [
          {
            'code' => '2186-5',
            'codeSystem' => 'cdcrec',
            'descriptor' => 'Not Hispanic or Latino',
            'codeSystemOid' => '2.16.840.1.113883.6.238'
          }
        ],
        '_type' => 'QDM::PatientCharacteristicEthnicity',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.56',
        'description' => nil,
        'category' => 'patient_characteristic',
        'qdmStatus' => 'ethnicity',
        'qdmVersion' => '5.3'
      },
      {
        'dataElementCodes' => [
          {
            'code' => '1002-5',
            'codeSystem' => 'cdcrec',
            'descriptor' => 'American Indian or Alaska Native',
            'codeSystemOid' => '2.16.840.1.113883.6.238'
          }
        ],
        '_type' => 'QDM::PatientCharacteristicRace',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.59',
        'description' => nil,
        'category' => 'patient_characteristic',
        'qdmStatus' => 'race',
        'qdmVersion' => '5.3'
      }
    ]
    dataElements data_elements_value

    after(:create) do |patient|
      create(:individual_result, patient_id: patient._id, bundleId: patient.bundleId)
    end

    factory :static_test_patient do
      familyName 'GP Geriatric'
      givenNames ['1 N']
      extendedData do
        { 'medical_record_number' => '1234' }.merge(extended_data_value)
      end
    end
  end
end
