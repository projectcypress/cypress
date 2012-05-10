module Cypress
  class DuplicateRemover

    def self.remove_duplicate_results(patients)
      seen_ids = Array.new
      new_patient_list = Array.new
      patients.each do |patient|
        if !seen_ids.include?(patient.value.patient_id.to_s)
          new_patient_list << patient
          seen_ids << patient.value.patient_id.to_s
        end
      end
      new_patient_list
    end
    
    def self.remove_duplicate_records(patients)
      seen_ids = Array.new
      new_patient_list = Array.new
      patients.each do |patient|
        if !seen_ids.include?(patient.id.to_s)
          new_patient_list << patient
          seen_ids << patient.id.to_s
        end
      end
      new_patient_list
    end
  end
end