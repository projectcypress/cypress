require 'test_helper'
class C4TaskTest < MiniTest::Test
  def setup
    collection_fixtures('product_tests', '_id', 'bundle_id')
    collection_fixtures('products', '_id')
    collection_fixtures('bundles', '_id')
    collection_fixtures('measures', '_id', 'bundle_id')
    collection_fixtures('records', '_id', 'bundle_id', 'test_id')
    collection_fixtures('patient_cache', '_id', 'bundle_id')
    @product_test = ProductTest.find('51703a883054cf84390000d3')
  end

  def after_teardown
    drop_database
  end

  def test_create
    assert @product_test.tasks.create({}, C4Task)
  end
end
