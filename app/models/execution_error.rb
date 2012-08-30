class ExecutionError
  
  include Mongoid::Document
  embedded_in :test_execution
  field :message, type: String
  field :msg_type, type: Symbol
  
  validates_presence_of :msg_type
  validates_presence_of :message
  
end