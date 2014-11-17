require 'test_helper'

class PatientCacheTest < ActiveSupport::TestCase
  include HealthDataStandards::CQM

  setup do
    collection_fixtures('bundles','_id')
    collection_fixtures('patient_cache','_id','bundle_id')
  end

  test "patient_counts_for_measures" do
    bundle_id = Moped::BSON::ObjectId.from_string("4fdb62e01d41c820f6000001")

    result = PatientCache.patient_counts_for_measures(
               bundle_id, ["99119911"],
               1293840000, :numerator)
    assert_equal 2, result.length
    assert result.any? {|r| r["_id"] == "01"}
    assert result.any? {|r| r["_id"] == "02"}
  end

  test "measures_to_patients_for_population" do
    bundle_id = Moped::BSON::ObjectId.from_string("4fdb62e01d41c820f6000001")

    result = PatientCache.measures_to_patients_for_population(
               bundle_id, ["99119911"],
               1293840000, :denominator)
    assert_equal 1, result.size
    assert_equal({'measure_id' => "99119911"}, result.first["_id"])
    assert_equal(["03", "04", "05"], result.first["patients"].sort)
  end
end