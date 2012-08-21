
class TestExecution
  include Mongoid::Document

  belongs_to :product_test
  embeds_many :errors

  field :execution_date, type: Integer
  field :expected_results, type: Hash
  field :status, type: Symbol
  field :state, type: Symbol
  scope :ordered_by_date, order_by(:execution_date => :desc)
  scope :order_by_state, order_by(:state => :asc)

  state_machine :state , :initial=> :pending do
    
    event :failed do
      transition :pending => :failed
    end
    
    event :pass do
      transition :pending => :passed
    end
    
    
    event :force_pass do
      transition all => :passed
    end
    
    
    event :force_fail do
      transition all => :failed
    end

    event :reset do
      transition all => :pending
    end
    
    
  end

  def count_errors
    errors.where({:msg_type=>:error}).count
  end
  
  def count_warnings
     errors.where({:msg_type=>:warning}).count
  end

end
