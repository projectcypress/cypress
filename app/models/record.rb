class Record
  include Mongoid::Document
  
  field :first, type: String
  field :last, type: String
  field :gender, type: String
  field :birthdate, type: Integer
end