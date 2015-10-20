class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :product_test
end
