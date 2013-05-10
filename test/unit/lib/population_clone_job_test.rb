require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase

  setup do 
  
  	collection_fixtures('patient_populations','_id')
  	collection_fixtures('records','_id','test_id','bundle_id')
    collection_fixtures('product_tests','_id','bundle_id')


  end
  	
  def test_perform
    assert_equal 13,  Record.count, "There should be 13 patient records installed"
    # no ids passed in , should use all of the records for the bundle the test is associated with, which would be 9
    pcj1 = Cypress::PopulationCloneJob.new('test_id' => '4f58f8de1d41c851eb000478')
    pcj1.perform
    assert_equal 21, Record.count
    assert_equal 9, Record.where(:test_id => '4f58f8de1d41c851eb000478').count 
    
    # ids passed in should clone just the 2 records
    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f636b3f1d41c851eb000491')
    pcj3.perform
    assert_equal 23, Record.count 
	  assert_equal 2, Record.where(:test_id => '4f636b3f1d41c851eb000491').count

        # ids passed in should clone just the 2 records
    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f636b3f1d41c851eb000491', 'randomization_ids' => [])
    pcj3.perform
    assert_equal 25, Record.count 
    assert_equal 4, Record.where(:test_id => '4f636b3f1d41c851eb000491').count

            # ids passed in should clone just the 2 records
    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f636b3f1d41c851eb000491', 'randomization_ids' => ['19','20'])
    pcj3.perform
    assert   [28,29].index(Record.count ), "Should be 28 or 29 records depedning on how many records were chossen for randomization"
    assert [7,8].index(Record.where(:test_id => '4f636b3f1d41c851eb000491').count), "should be 3 or 4 records depedning on how many records were chossen for randomization"
  end

end
