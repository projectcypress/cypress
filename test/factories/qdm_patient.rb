FactoryBot.define do
  factory :qdm_patient, class: QDM::Patient do
    qdmVersion { '5.4' }
    birthDatetime { DateTime.new(1950, 1, 1).utc }
    data_elements_value = [
      {
        'authorDatetime' => '2017-09-28T08:00:00.000+00:00',
        'qdmCategory' => 'procedure',
        'components' => [],
        'dataElementCodes' => [
          {
            'codeSystem' => 'SNOMEDCT',
            'system' => '2.16.840.1.113883.6.96',
            'code' => '210'
          },
          {
            'codeSystem' => 'CPT',
            'system' => '2.16.840.1.113883.6.12',
            'code' => '60'
          }
        ],
        'description' => 'Procedure, Performed: Pneumococcal Vaccine Administered',
        'hqmfOid' => '2.16.840.1.113883.3.560.1.6',
        'qdmStatus' => 'performed',
        'qdmVersion' => '5.3',
        'relevantPeriod' => {
          'low' => '2017-09-28T08:00:00+00:00',
          'high' => '2017-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        },
        '_type' => 'QDM::ProcedurePerformed'
      },
      {
        'dataElementCodes' => [
          {
            'codeSystem' => 'SNOMEDCT',
            'system' => '2.16.840.1.113883.6.96',
            'code' => '24'
          }
        ],
        '_type' => 'QDM::Diagnosis',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.4.110',
        'qrdaOid' => '2.16.840.1.113883.10.20.24.3.135',
        'qdmCategory' => 'condition',
        'qdmVersion' => '5.3',
        'description' => 'Diagnosis: Allergy to Eggs',
        'prevalencePeriod' => {
          'low' => '2017-09-28T08:00:00+00:00',
          'high' => '2017-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        }
      },
      {
        'dataElementCodes' => [
          {
            'codeSystem' => 'SNOMEDCT',
            'system' => '2.16.840.1.113883.6.96',
            'code' => '504'
          }
        ],
        '_type' => 'QDM::Diagnosis',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.4.110',
        'qrdaOid' => '2.16.840.1.113883.10.20.24.3.135',
        'qdmCategory' => 'condition',
        'qdmVersion' => '5.3',
        'description' => 'Diagnosis: Diabetes',
        'prevalencePeriod' => {
          'low' => '2017-09-28T08:00:00+00:00',
          'high' => '2017-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        }
      },
      {
        'qdmCategory' => 'encounter',
        'dataElementCodes' => [
          {
            'codeSystem' => 'SNOMEDCT',
            'system' => '2.16.840.1.113883.6.96',
            'code' => '720'
          }
        ],
        'description' => 'Encounter, Performed: Office Visit',
        'hqmfOid' => '2.16.840.1.113883.3.560.1.79',
        'qdmStatus' => 'performed',
        'qdmVersion' => '5.3',
        'relevantPeriod' => {
          'low' => '2017-09-28T08:00:00+00:00',
          'high' => '2017-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        },
        '_type' => 'QDM::EncounterPerformed'
      },
      {
        'qdmCategory' => 'encounter',
        'dataElementCodes' => [
          {
            'codeSystem' => 'SNOMEDCT',
            'system' => '2.16.840.1.113883.6.96',
            'code' => '5814'
          }
        ],
        'description' => 'Encounter, Performed: Office Visit',
        'hqmfOid' => '2.16.840.1.113883.3.560.1.79',
        'qdmStatus' => 'performed',
        'qdmVersion' => '5.3',
        'relevantPeriod' => {
          'low' => '2017-09-28T08:00:00+00:00',
          'high' => '2017-09-28T08:00:00+00:00',
          'lowClosed' => true,
          'highClosed' => true
        },
        '_type' => 'QDM::EncounterPerformed'
      },
      {
        'qdmCategory' => 'patient_characteristic',
        'dataElementCodes' => [
          {
            'code' => 'F',
            'codeSystem' => 'AdministrativeGender',
            'descriptor' => 'F',
            'system' => '2.16.840.1.113883.5.1'
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
            'codeSystem' => 'LOINC',
            'system' => '2.16.840.1.113883.6.1'
          }
        ],
        '_type' => 'QDM::PatientCharacteristicBirthdate',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.54',
        'description' => nil,
        'qdmCategory' => 'patient_characteristic',
        'qdmStatus' => 'birthdate',
        'qdmVersion' => '5.3',
        'birthDatetime' => '1950-01-01T00:00:00+00:00'
      },
      {
        'dataElementCodes' => [
          {
            'code' => '2186-5',
            'codeSystem' => 'cdcrec',
            'descriptor' => 'Not Hispanic or Latino',
            'system' => '2.16.840.1.113883.6.238'
          }
        ],
        '_type' => 'QDM::PatientCharacteristicEthnicity',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.56',
        'description' => nil,
        'qdmCategory' => 'patient_characteristic',
        'qdmStatus' => 'ethnicity',
        'qdmVersion' => '5.3'
      },
      {
        'dataElementCodes' => [
          {
            'code' => '1',
            'codeSystem' => 'sop',
            'descriptor' => 'Medicare',
            'system' => '2.16.840.1.113883.3.221.5'
          }
        ],
        'relevantPeriod' => {
          'low' => '2017-09-28T08:00:00+00:00',
          'high' => nil,
          'lowClosed' => true,
          'highClosed' => true
        },
        '_type' => 'QDM::PatientCharacteristicPayer',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.4.58',
        'description' => nil,
        'qdmCategory' => 'patient_characteristic',
        'qdmStatus' => 'payer',
        'qdmVersion' => '5.3'
      },
      {
        'dataElementCodes' => [
          {
            'code' => '1002-5',
            'codeSystem' => 'cdcrec',
            'descriptor' => 'American Indian or Alaska Native',
            'system' => '2.16.840.1.113883.6.238'
          }
        ],
        '_type' => 'QDM::PatientCharacteristicRace',
        'hqmfOid' => '2.16.840.1.113883.10.20.28.3.59',
        'description' => nil,
        'qdmCategory' => 'patient_characteristic',
        'qdmStatus' => 'race',
        'qdmVersion' => '5.3'
      }
    ]
    dataElements { data_elements_value }
  end
end
