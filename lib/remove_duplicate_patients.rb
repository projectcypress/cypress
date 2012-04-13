module Cypress
  class DuplicateRemover

    def self.remove_duplicates(patients)
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
    
  end
end