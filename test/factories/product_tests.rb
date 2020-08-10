FactoryBot.define do
  factory :product_test, class: MeasureTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :product_test_static_result do
      name { 'Static Result' }
      _type { 'MeasureTest' }
      cms_id { 'CMS1234' }
      aug_record = [{ 'original_patient_id' => '123',
                      'medical_record_number' => '1234',
                      'first' => %w[Dental_Peds Denial_Peds],
                      'last' => %w[A A],
                      'gender' => %w[M M] }]
      augmented_patients { aug_record }

      measure_ids { ['40280382-5FA6-FE85-0160-0918E74D2075'] }
      association :provider, factory: :default_provider
      association :product, factory: :product_static_bundle
      after(:create) do |pt|
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id)
        patient.correlation_id = pt.id
        patient.medical_record_number = '1989db70-4d42-0135-8680-30999b0ed66f'
        # patient.qdmPatient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [QDM::Code.new('1002-5', '2.16.840.1.113883.6.238')])
        # patient.qdmPatient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [QDM::Code.new('2186-5', '2.16.840.1.113883.6.238')])
        # patient.qdmPatient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [QDM::Code.new('F', '2.16.840.1.113883.12.1')])
        # patient.qdmPatient.dataElements << QDM::PatientCharacteristicPayer.new(dataElementCodes: [QDM::Code.new('1', '2.16.840.1.113883.6.238')])
        patient.save
        aug_record[0]['original_patient_id'] = patient._id
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1',
               'IPP' => 1,
               'DENOM' => 1,
               'DENEX' => 0,
               'NUMER' => 0)
        pt.augmented_patients = aug_record
        ar = ProductTestAggregateResult.create(product_test: pt, measure_id: pt.measures.first.id)
        CQM::IndividualResult.where(correlation_id: pt.id).each do |ir|
          ar.add_individual_result(ir)
        end
        ar.save
        pt.save
      end
    end

    factory :cv_product_test_static_result do
      name { 'Static Result' }
      _type { 'MeasureTest' }
      cms_id { 'CMS1234' }
      aug_record = [{ 'original_patient_id' => '123',
                      'medical_record_number' => '1234',
                      'first' => %w[Dental_Peds Denial_Peds],
                      'last' => %w[A A],
                      'gender' => %w[M M] }]
      augmented_patients { aug_record }

      measure_ids { ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }
      association :provider, factory: :default_provider
      association :product, factory: :product_static_bundle
      after(:create) do |pt|
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id)
        patient.correlation_id = pt.id
        patient.medical_record_number = '1989db70-4d42-0135-8680-30999b0ed66f'
        patient.save
        aug_record[0]['original_patient_id'] = patient._id
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1',
               'IPP' => 1,
               'MSRPOPL' => 1,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 1',
               'IPP' => 0,
               'MSRPOPL' => 0,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 2',
               'IPP' => 0,
               'MSRPOPL' => 0,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 3',
               'IPP' => 1,
               'MSRPOPL' => 1,
               'MSRPOPLEX' => 0)
        pt.augmented_patients = aug_record
        ar = ProductTestAggregateResult.create(product_test: pt, measure_id: pt.measures.first.id)
        CQM::IndividualResult.where(correlation_id: pt.id).each do |ir|
          ar.add_individual_result(ir)
        end
        ar.save
        pt.save
      end
    end
  end
end
