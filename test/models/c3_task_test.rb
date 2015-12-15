require 'test_helper'
class C3TaskTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache')
  end

  def test_create
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    assert ptest.tasks.create({}, C3Task)
  end
end
