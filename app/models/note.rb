class Note

  include Mongoid::Document
  
  embedded_in :vendor, inverse_of:  :notes
  
  field :time, type: Time
  field :text, type: String
end
  