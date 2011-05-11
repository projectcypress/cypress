class Record
  include Mongoid::Document
  
  field :first, type: String
  field :last, type: String
  field :gender, type: String
  field :birthdate, type: Integer
  
  embeds_many :encounters, as: :entry_list, class_name: "Entry"
end