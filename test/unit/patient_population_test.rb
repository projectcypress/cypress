require 'test_helper'

class PatientPopulationTest < ActiveSupport::TestCase

  setup do

    collection_fixtures('patient_populations','_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('patient_cache','_id','bundle_id')
  end

  test "Should return installed patient populations" do
    populations = PatientPopulation.installed

    assert populations[0]._id.to_s == "4f57a52b1d41c851cf000001"
    assert populations[1]._id.to_s == "4f57a52b1d41c851cf000002"
  end

  test "Should return min coverage for set of measures" do
    measures = []
    minset = PatientPopulation.min_coverage(measures,Bundle.active.first)
    assert_equal 0, minset[:minimal_set].length
    assert_equal 0, minset[:overflow].length

    measures =['99119911','99119922','99119933','99119944']

    minset = PatientPopulation.min_coverage(measures,Bundle.active.first)


    assert  [4,3].index(minset[:minimal_set].length), "Should be 3 or 4 - depends on which denom/exclusions are picked at random"
    assert_equal 6-minset[:minimal_set].length, minset[:overflow].length

 end


end
