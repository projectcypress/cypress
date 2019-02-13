FactoryBot.define do
  factory :compiled_result, class: CompiledResult do
    IPP { true }
    individual_results_hash = { 'PopulationCriteria1' => { 'IPP' => 1,
                                                           'MSRPOPL' => 1,
                                                           'MSRPOPLEX' => 0 },
                                'PopulationCriteria1 - Stratification 1' => { 'IPP' => 0,
                                                                              'MSRPOPL' => 0,
                                                                              'MSRPOPLEX' => 0,
                                                                              'STRAT' => 0 },
                                'PopulationCriteria1 - Stratification 2' => { 'IPP' => 0,
                                                                              'MSRPOPL' => 0,
                                                                              'MSRPOPLEX' => 0,
                                                                              'STRAT' => 0 },
                                'PopulationCriteria1 - Stratification 3' => { 'IPP' => 1,
                                                                              'MSRPOPL' => 1,
                                                                              'MSRPOPLEX' => 0,
                                                                              'STRAT' => 1 } }
    individual_results { individual_results_hash }
    factory :individual_bundle_result do
      transient do
        bundleId { Bundle.find_by(name: 'Static Bundle')._id }
      end
      measure_id { Measure.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE')._id }
      correlation_id { bundleId }
    end
  end
end
