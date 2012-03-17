# TestPopulations are subsets of the Master Patient List. Each Test that is executed for a Product uses a TestPopulation
# to keep track of the Records who will be considered in measure calculation.

class PatientPopulation
  include Mongoid::Document
  
  belongs_to :product_test
  has_and_belongs_to_many :records
  
  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :patient_ids, type: Array

  def self.installed
    PatientPopulation.order_by([["name", :asc]]).to_a
  end
  
  def self.min_coverage(measures)
     measures_to_patients = MONGO_DB['patient_cache'].group(:key => ["value.measure_id", "value.sub_id", "value.test_id"], 
                              :cond => {"value.test_id"=>nil, "value.numerator"=>true,"value.measure_id"=>{"$in"=>measures}},
                              :initial => {:patients => []},
                              :reduce => 
                              'function(o,prev){prev.patients.push(o.value.patient_id);}')

    patients = {}
    measures_to_patients.sort! {|a,b| 
       al = a ? a['patients'].length : 0
       bl = b ? b['patients'].length : 0
       al <=> bl
      }

    measures_to_patients.each do |val|
      val["patients"].each do |p|
         patients[p] ||= []
         entry = [val["value.measure_id"],val["value.sub_id"]]
         patients[p].push entry unless patients[p].index(entry) 
      end
    end
    
    p_list = []
    m_list = []
    measures_to_patients.each do |val|
      entry = [val["value.measure_id"],val["value.sub_id"]]
      unless m_list.index(entry) 
        m_list.push(entry)
        patient = nil
        val["patients"].each do |p|
          patient ||= p
          patient =(patients[patient].length < patients[p].length) ? p : patient
        end
        p_list.push(patient)
        m_list.concat( patients[patient] )
      end
    end
    p_list
 end
end


