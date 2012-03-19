require 'test_helper'

class MeasureTest < ActiveSupport::TestCase

  setup do
    #collection_fixtures('vendors', '_id')
    #collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
    @measure1 = Measure.where(:id => "0001").first
  end

  test "Should have key" do
    assert @measure1.key == "0001"
  end
  
  test "Should have display name" do
    assert @measure1.display_name == "0001 - Asthma Assessment"
  end
  
  test "Should have measure id" do
    assert @measure1.measure_id == "0001"
  end
  
  test "Should list installed measures" do
    measures = Measure.installed
    
    assert measures.count == 2
    assert measures.index{|m| m.measure_id=="0001"} != nil
    assert measures.index{|m| m.measure_id=="0002"} != nil
  end

  test "Should list top levels" do
    measures = Measure.top_level
    
    assert measures.count == 2
    assert measures.index{|m| m.measure_id=="0001"} != nil
    assert measures.index{|m| m.measure_id=="0002"} != nil
  end
  
end
