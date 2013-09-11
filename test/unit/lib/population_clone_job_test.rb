require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase

  setup do 
  
  	collection_fixtures('patient_populations','_id')
  	collection_fixtures('records','_id','test_id','bundle_id')
    collection_fixtures('product_tests','_id','bundle_id')


  end
  	
  def test_perform

    assert_equal 15,  Record.count, "There should be 15 patient records installed"

    pcj1 = Cypress::PopulationCloneJob.new('subset_id' => 'all','test_id' => '4f58f8de1d41c851eb000478')

    pcj1.perform
    assert_equal 23, Record.count
    assert_equal 9, Record.where(:test_id => '4f58f8de1d41c851eb000478').count 
    

    pcj2 = Cypress::PopulationCloneJob.new('subset_id' => 'test','test_id' => '4f5a606b1d41c851eb000484')
    pcj2.perform
    assert_equal 31, Record.count
    assert_equal 8, Record.where(:test_id => '4f5a606b1d41c851eb000484').count



        # ids passed in should clone just the 2 records
    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f636b3f1d41c851eb000491', 'randomization_ids' => [])
    pcj3.perform
    assert_equal 33, Record.count 
    assert_equal 2, Record.where(:test_id => '4f636b3f1d41c851eb000491').count

            # ids passed in should clone just the 2 records
    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f636b3f1d41c851eb000491', 'randomization_ids' => ['19','20','19','20','19','20'])
    pcj3.perform
    r_count = Record.count
    assert   (r_count >= 36 && r_count <= 40), "Should be 36 or 40 records depedning on how many records were chossen for randomization"
    count =Record.where(:test_id => '4f636b3f1d41c851eb000491').count
    assert (count >= 3 && count <=7), "should be 3 or 7 records depedning on how many records were chossen for randomization was #{count} "
  end

end
