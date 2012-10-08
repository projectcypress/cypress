class ExecutionError
  
  include Mongoid::Document
  embedded_in :test_execution
  field :message, type: String
  field :msg_type, type: Symbol
  field :measure_id, type: String
  
  validates_presence_of :msg_type
  validates_presence_of :message

  scope :by_type, ->(type){where(msg_type: type)}
  
end