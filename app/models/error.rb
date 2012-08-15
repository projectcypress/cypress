class Error
  
  include Mongoid::Document
  embedded_in :test_execution
  field :message, :type String

end