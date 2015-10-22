require 'test_helper'
class C4TaskTest < MiniTest::Test
  def setup
    collection_fixtures('product_tests','products', 'bundles', 
                        'measures','records','patient_cache')
    
    @product_test = ProductTest.find('51703a883054cf84390000d3')
  end

  def after_teardown
    drop_database
  end

  def test_create
    assert @product_test.tasks.create({}, C4Task)
  end
end
