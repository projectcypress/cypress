# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  
  has_and_belongs_to_many :patient_population
   
  field :measures, type: Hash
  field :race
  field :ethnicity
  
  def self.minimal_set(measure_ids)

    # Find the IDs of all Records for our minimal set and overflow
    minimal_set = PatientPopulation.min_coverage(measure_ids)
    minimal_ids = minimal_set[:minimal_set]
    overflow_ids = minimal_set[:overflow]
    
    # Query to find the actual Records for our minmal set and overflow
    patient_list = Record.where( { _id: { "$in" => minimal_ids } } ).only(:_id, :first, :last, :birthdate, :gender, :patient_id).order_by([["_id", :desc]]).to_a
    overflow = Record.where({ _id: { "$in" => overflow_ids } }).only(:_id, :first, :last, :birthdate, :gender, :patient_id).to_a
    
    # Get the results that are relevant to the measures and patients the user asked for
    results = Result.where({'value.measure_id' => { "$in" => measure_ids}, 'value.patient_id' => { "$in" => minimal_ids | overflow_ids } })
    
    # Use the relevant results to build @coverage of each measure
    coverage = {}
    buckets = ["denominator", "numerator", "exclusions", "antinumerator"]
    results.each do |result|
      # Skip results that don't fall into any of the buckets
      next if !result.value['numerator'] && !result.value['denominator'] && !result.value['antinumerator'] && !result.value['exclusions']
      
      # Identify the measure to which this result is referring
      measure = "#{result.value.measure_id}#{result.value.sub_id}".to_s

      # Add this measure to the patients for easy lookup in both directions (i.e. patients <-> measures)
      patient_index = patient_list.index{|patient| patient.id == result.value.patient_id}
      if patient_index
        patient = patient_list[patient_index]
      else
        patient_index = overflow.index{|patient| patient.id == result.value.patient_id}
        patient = overflow[patient_index]
      end
      patient['measures'] ||= []
      patient['measures'] << measure
      
      # Add the patient along with their placement in buckets to this measure
      coverage[measure] ||= {}
      coverage[measure][patient._id] = {}
      buckets.each do |bucket|
        bucket_value = result.value[bucket] ? 1 : 0
        coverage[measure][patient._id][bucket] = bucket_value
      end
    end
    
    {patient_list: patient_list, overflow: overflow, coverage: coverage}

  end
  
end