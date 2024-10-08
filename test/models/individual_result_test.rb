# frozen_string_literal: true

require 'test_helper'

class IndividualResultTest < ActiveSupport::TestCase
  setup do
    @bundle = FactoryBot.create(:static_bundle)
    @measure = @bundle.measures.first
    @patient = @bundle.patients.first
  end

  def test_individual_result_relevant_to_measure_true_statement_result
    statement_results = [{ 'final' => 'TRUE',
                           'statement_name' => 'Previously on ADHD Medication' }]
    individual_result = CQM::IndividualResult.new(IPP: 0, measure: @measure, patient: @patient, statement_results:)
    @measure.hqmf_id = '2C928082-7B1B-AB09-017B-28E8655E02F2'
    assert @measure.individual_result_relevant_to_measure(individual_result)
  end

  def test_individual_result_relevant_to_measure_false_statement_result
    statement_results = [{ 'final' => 'FALSE',
                           'statement_name' => 'Previously on ADHD Medication' }]
    individual_result = CQM::IndividualResult.new(IPP: 0, measure: @measure, patient: @patient, statement_results:)
    @measure.hqmf_id = '2C928082-7B1B-AB09-017B-28E8655E02F2'
    assert_not @measure.individual_result_relevant_to_measure(individual_result)
  end

  def test_no_issues
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1 }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert_empty issues
  end

  def test_issue_for_bad_ipp
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 2 }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'Calculated value (2) for IPP (HHH) does not match expected value (1)'
  end

  def test_issue_for_bad_result
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => { 'value' => 60, 'unit' => '/min' } }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR of [50 /min] does not match [60 /min]'
  end

  def test_issue_for_unexpected_result
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => nil }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => { 'value' => 60, 'unit' => '/min' } }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR not expected'
  end

  def test_issue_for_missing_result
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => nil }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR of [50 /min] is missing'
  end

  def test_issue_for_good_multiple_results
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } },
                              { 'FirstResult' => { 'value' => 40, 'unit' => '/min' } }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } },
                                  { 'FirstResult' => { 'value' => 40, 'unit' => '/min' } }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.empty?
  end

  def test_issue_for_swapped_multiple_results
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } },
                              { 'FirstResult' => { 'value' => 40, 'unit' => '/min' } }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => { 'value' => 40, 'unit' => '/min' } },
                                  { 'FirstResult' => { 'value' => 50, 'unit' => '/min' } }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.empty?
  end

  def test_issue_for_bad_multiple_results
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } },
                              { 'FirstResult' => { 'value' => 50, 'unit' => '/min' } }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } },
                                  { 'FirstResult' => { 'value' => 40, 'unit' => '/min' } }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR of [50 /min, 50 /min] does not match [40 /min, 50 /min]'
  end

  def test_issue_for_missing_multiple_results
    @measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    @measure.save
    statement_results = [{ 'raw' =>
                           { 'firstHR' =>
                             [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } },
                              { 'FirstResult' => { 'value' => 50, 'unit' => '/min' } }] },
                           'statement_name' => 'Results' }]
    bad_statement_results = [{ 'raw' =>
                               { 'firstHR' =>
                                 [{ 'FirstResult' => { 'value' => 50, 'unit' => '/min' } }] },
                               'statement_name' => 'Results' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR of [50 /min, 50 /min] does not match [50 /min]'
  end

  def test_issue_for_missing_risk_variable
    @measure.hqmf_id = '2C928082-7FAC-C041-017F-B75D24BE0605'
    sde = [{ 'statement_name' => 'Risk Variable Anemia' }]
    @measure.population_sets.first.supplemental_data_elements = sde
    @measure.save
    statement_results = [{ 'raw' =>
                           [{ '_type' => 'QDM::EncounterPerformed',
                              'qdmTitle' => 'Encounter, Performed',
                              'id' => '627562c2c1c388f89d2ab681' }],
                           'statement_name' => 'Risk Variable Anemia' }]
    bad_statement_results = [{ 'raw' =>
                               [{ '_type' => 'QDM::EncounterPerformed',
                                  'qdmTitle' => 'Encounter, Performed',
                                  'id' => '627562c2c1c388f89d2ab681' }],
                               'statement_name' => 'Risk Variable Asthma' }]
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1, 'statement_results' => bad_statement_results }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'Risk Variable Anemia - Not Found in File'
  end

  def test_collect_risk_variable_values
    @measure.hqmf_id = '2C928082-7FAC-C041-017F-B75D24BE0605'
    sde = [{ 'statement_name' => 'Risk Variable Anemia' }, { 'statement_name' => 'Risk Variable Asthma' }, { 'statement_name' => 'Risk Variable Blank' }]
    @measure.population_sets.first.supplemental_data_elements = sde
    @measure.save
    statement_results = [{ 'raw' =>
                           [{ '_type' => 'QDM::EncounterPerformed',
                              'qdmTitle' => 'Encounter, Performed',
                              'id' => '627562c2c1c388f89d2ab681' }],
                           'statement_name' => 'Risk Variable Asthma' },
                         { 'raw' =>
                           { 'FirstHeartRate' =>
                             [{ 'EncounterId' => '627562f5c1c388f89d2ac2f9',
                                'FirstResult' => { 'value' => 65, 'unit' => '/min' },
                                'Timing' => '2021-06-15T05:00:00.000+00:00' }] },
                           'statement_name' => 'Risk Variable Anemia' }]
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, patient: @patient, statement_results:)
    collected_risk_variables = individual_result.collect_risk_variables
    assert collected_risk_variables['Risk Variable Asthma'].size == 1
    assert collected_risk_variables['Risk Variable Anemia'].size == 1
    assert collected_risk_variables['Risk Variable Blank'].blank?
  end
end
