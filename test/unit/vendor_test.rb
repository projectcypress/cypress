require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('vendors', '_id')
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
  end

  test "Finding the fixture vendor" do
    vendors = Vendor.all.to_a
    assert vendors.size==1
    vendor = vendors[0]
    assert vendor.name=='EHRSrUS'
  end

  test "Vendor gets expected results correctly" do
    vendor = Vendor.all.to_a[0]
    assert vendor.measure_ids.size==2
    results = vendor.expected_results
    assert results.size==2
    assert results[0]['key']=='0001'
    assert results[0]['denominator']==9
    assert results[1]['key']=='0002'
    assert results[1]['denominator']==2
  end

  test "Vendor compares expected and reported results correctly" do
    vendor = Vendor.all.to_a[0]
    assert vendor.measure_ids.size==2
    results = vendor.expected_results
    assert !vendor.passing?
    assert vendor.passed?(results[0])
    assert !vendor.passed?(results[1])
  end

  test "Vendor returns passing and failing measures correctly" do
    vendor = Vendor.all.to_a[0]
    passing = vendor.passing_measures
    assert passing.size==1
    assert passing[0]['id']=='0001'
    failing = vendor.failing_measures
    assert failing.size==1
    assert failing[0]['id']=='0002'
  end
  
  test "Vendor imports PQRI" do
    vendor = Vendor.new
    doc = Nokogiri::XML(File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri.xml')))
    vendor.extract_reported_from_pqri(doc)
    assert vendor.reported_results != nil
    assert vendor.reported_results.size==2
    assert vendor.reported_results['0421a'] != nil
    assert vendor.reported_results['0421a']['denominator'] == 80
    assert vendor.reported_results['0421a']['numerator'] == 39
    assert vendor.reported_results['0421a']['exclusions'] == 0
    assert vendor.reported_results['0421b'] != nil
    assert vendor.reported_results['0421b']['denominator'] == 300
    assert vendor.reported_results['0421b']['numerator'] == 71
    assert vendor.reported_results['0421b']['exclusions'] == 0
  end

end
