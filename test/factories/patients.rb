# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient, class: BundlePatient do
    transient do
      seq_id { 1 }
    end

    medical_record_number { "#{seq_id}989db70-4d42-0135-8680-20999b0ed66f" }

    factory :static_bundle_patient, class: BundlePatient do
      familyName { 'MPL record' }
      givenNames { [seq_id.to_s] }
      qdmPatient { FactoryBot.build(:qdm_patient) }

      after(:create) do |patient|
        provider = create(:default_provider)
        proportion_ir = create(:cqm_individual_result,
                               'correlation_id' => patient.bundleId,
                               'patient_id' => patient.id,
                               'cqm_patient' => patient.id,
                               'population_set_key' => 'PopulationCriteria1',
                               'IPP' => 0,
                               'DENOM' => 0,
                               'DENEX' => 0,
                               'NUMER' => 0)
        cv_ir = create(:cv_cqm_individual_result,
                       'correlation_id' => patient.bundleId,
                       'patient_id' => patient.id,
                       'cqm_patient' => patient.id,
                       'population_set_key' => 'PopulationCriteria1',
                       'IPP' => 1,
                       'MSRPOPL' => 1,
                       'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => patient.bundleId,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => cv_ir.measure_id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 1',
               'IPP' => 0,
               'MSRPOPL' => 0,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => patient.bundleId,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => cv_ir.measure_id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 2',
               'IPP' => 0,
               'MSRPOPL' => 0,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => patient.bundleId,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => cv_ir.measure_id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 3',
               'IPP' => 1,
               'MSRPOPL' => 1,
               'MSRPOPLEX' => 0)
        patient.measure_relevance_hash = {}
        patient.measure_relevance_hash[proportion_ir.measure_id.to_s] = { 'IPP' => false }
        patient.measure_relevance_hash[cv_ir.measure_id.to_s] = { 'IPP' => true, 'MSRPOPL' => true }
        patient.providers << provider
        patient.save!
      end
    end

    factory :static_test_patient, class: ProductTestPatient do
      familyName { 'A' }
      givenNames { ['Dental_Peds'] }
      qdmPatient { FactoryBot.build(:qdm_patient) }

      after(:create) do |patient|
        provider = create(:default_provider)
        patient.providers << provider
        patient.save!
      end
    end

    factory :vendor_test_patient, class: VendorPatient do
      familyName { 'A' }
      givenNames { ['Dental_Peds'] }
      qdmPatient { FactoryBot.build(:qdm_patient) }

      after(:create) do |patient|
        patient.measure_relevance_hash = {}
        patient.measure_relevance_hash[Measure.find_by(bundle_id: patient.bundle.id, hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE')._id.to_s] = { 'IPP' => true, 'MSRPOPL' => true }
        # patient - create individual_results for patient? or create()?
        IndividualResult.new('measure_id' => Measure.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE', bundle_id: patient.bundle.id)._id,
                             'correlation_id' => patient.correlation_id,
                             'patient_id' => patient.id,
                             'cqm_patient' => patient.id,
                             'population_set_key' => 'PopulationCriteria1',
                             'IPP' => 1,
                             'MSRPOPL' => 1,
                             'MSRPOPLEX' => 0).save
        provider = create(:default_provider)
        patient.providers << provider
        patient.save!
      end
    end
  end
end
