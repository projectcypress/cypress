require 'test_helper'

class RaceTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('vendors', '_id')
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
  end

  test "first test" do
    assert true
  end
end
