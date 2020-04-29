require 'test_helper'

class IndividualResultTest < ActiveSupport::TestCase
  setup do
    @bundle = FactoryBot.build(:static_bundle)
    @measure = @bundle.measures.first
  end

  def test_no_issues
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 1 }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert_empty issues
  end

  def test_issue_for_bad_ipp
    options = { population_set: { populations: { 'IPP' => { hqmf_id: 'HHH' } } } }
    calculated = { 'IPP' => 2 }
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'Calculated value (2) for IPP (HHH) does not match expected value (1)'
  end

  def test_issue_for_bad_result
    @measure.hqmf_set_id = 'FA75DE85-A934-45D7-A2F7-C700A756078B'
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
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, statement_results: statement_results)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR of 50 /min does not match 60 /min'
  end

  def test_issue_for_unexpected_result
    @measure.hqmf_set_id = 'FA75DE85-A934-45D7-A2F7-C700A756078B'
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
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, statement_results: statement_results)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR not expected'
  end

  def test_issue_for_missing_result
    @measure.hqmf_set_id = 'FA75DE85-A934-45D7-A2F7-C700A756078B'
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
    individual_result = CQM::IndividualResult.new(IPP: 1, measure: @measure, statement_results: statement_results)
    _passed, issues = individual_result.compare_results(calculated, options, false)
    assert issues.include? 'firstHR of 50 /min is missing'
  end
end
