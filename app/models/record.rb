class Record
  include Mongoid::Document
  
  field :first, type: String
  field :last, type: String
  field :gender, type: String
  field :birthdate, type: Integer
  
  [:allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
   :medications, :procedures, :results, :social_history, :vital_signs].each do |section|
    embeds_many section, as: :entry_list, class_name: "Entry"
  end
end