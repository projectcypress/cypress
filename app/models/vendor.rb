class Vendor

  include Mongoid::Document

  # Vendor Details
  field :name, type: String
  field :poc, type: String
  field :tel, type: String
  field :email, type: String
  
  # Proctor Details
  field :proctor, type: String
  field :proctor_tel, type: String
  field :proctor_email, type: String
  
  # Test Details
  field :effective_date, type: Integer
  field :measure_ids, type: Array
  field :patient_gen_job, type: String


end