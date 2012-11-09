require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase

  setup do 
  
  	collection_fixtures('patient_populations','_id')
  	collection_fixtures('records','_id','test_id')
  end
  	
  def test_perform
    assert_equal 6,  Record.count, "There should be 6 patient records installed"

    pcj1 = Cypress::PopulationCloneJob.new('subset_id' => 'all','test_id' => '4f5a606b1d41c851eb000483')
    pcj1.perform
    assert_equal 11, Record.count
    assert_equal 5, Record.where(:test_id => '4f5a606b1d41c851eb000483').count 
    
    pcj2 = Cypress::PopulationCloneJob.new('subset_id' => 'test','test_id' => '4f5a606b1d41c851eb000484')
    pcj2.perform
    assert_equal 13, Record.count
    assert_equal 2, Record.where(:test_id => '4f5a606b1d41c851eb000484').count

    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f5a606b1d41c851eb000485')
    pcj3.perform
    assert_equal 15, Record.count 
	  assert_equal 2, Record.where(:test_id => '4f5a606b1d41c851eb000485').count
  end

end
