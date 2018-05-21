# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient, class: Patient do
    sequence(:familyName) { |i| "Patient Name #{i}" }
    sequence(:givenNames) { |n| [ n.to_s ] }
    qdmVersion "5.3"
    birthDatetime 1_340_323_200
    extendedDataValue = {
      'medical_record_assigner' => 'Bonnie',
      'notes' => "70yo female; DExcl 56,90 Num 127,130 DExcep 139,149\n*17qdes\n*Pt w h/o advancing dementia and heart failure. Suffered multiple fractures requiring surgery and occ therapy."
    }
    sequence(:extendedData) do |i|
      {
        'medical_record_number' => "#{i}989db70-4d42-0135-8680-20999b0ed66f"
      }.merge(extendedDataValue)
    end
    dataElementsValue = [{
        "authorDatetime" => "2012-09-28T08:00:00.000+00:00",
        "category" => "procedure",
        "components" => [],
        "dataElementCodes" => [
          {
            "codeSystem" => "SNOMED-CT",
            "code" => "210"
          },
          {
            "codeSystem" => "CPT",
            "code" => "60"
          }
        ],
        "description" => "Procedure, Performed: Pneumococcal Vaccine Administered",
        "hqmfOid" => "2.16.840.1.113883.3.560.1.6",
        "qdmStatus" => "performed",
        "qdmVersion" => "5.3",
        "relevantPeriod" => {
          "low" => "2012-09-28T08:00:00+00:00",
          "high" => "2012-09-28T08:00:00+00:00",
          "lowClosed" => true,
          "highClosed" => true
        },
        "_type" => "QDM::ProcedurePerformed"
      },
      {
        "category" => "patient_characteristic",
        "dataElementCodes" => [
          {
            "code" => "F",
            "codeSystem" => "AdministrativeGender",
            "descriptor" => "F",
            "codeSystemOid" => "2.16.840.1.113883.5.1"
          }
        ],
        "hqmfOid" => "2.16.840.1.113883.10.20.28.3.55",
        "qdmStatus" => "gender",
        "qdmVersion" => "5.3",
        "_type" => "QDM::PatientCharacteristicSex"
      }
    ]
    dataElements dataElementsValue

    factory :static_test_patient do
      familyName 'GP Geriatric'
      givenNames ['1 N']
      extendedData do
        { 'medical_record_number' => '1234' }.merge(extendedDataValue)
      end
    end
  end
end
