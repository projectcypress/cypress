require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase

  setup do 
  
  	collection_fixtures('patient_populations','_id')
  	collection_fixtures('records','_id','test_id')
  end
  	
  def test_perform
    assert Record.count == 3

    pcj1 = Cypress::PopulationCloneJob.new('subset_id' => 'all','test_id' => '4f5a606b1d41c851eb000483')
    pcj1.perform
    assert_equal 5, Record.count
    assert_equal 2, Record.where(:test_id => '4f5a606b1d41c851eb000483').count 
    
    pcj2 = Cypress::PopulationCloneJob.new('subset_id' => 'test','test_id' => '4f5a606b1d41c851eb000484')
    pcj2.perform
    assert_equal 7, Record.count
    assert_equal 2, Record.where(:test_id => '4f5a606b1d41c851eb000484').count

    pcj3 = Cypress::PopulationCloneJob.new('patient_ids' => ['19','20'],'test_id' => '4f5a606b1d41c851eb000485')
    pcj3.perform
    assert_equal 9, Record.count 
	  assert_equal 2, Record.where(:test_id => '4f5a606b1d41c851eb000485').count
  end

end
