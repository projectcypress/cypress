module Cypress
  # This is Resque job that will create records for a ProductTest. Currently you have the choice between doing a full clone of the test deck
  # or a specific subset to cover the 3 core measures. In the near future we will support more options to make very customized TD subsets.
  # For now, a subset_id of 'core20' will mean the 3 core measures. If that parameter does not exist, we copy the whole deck. For example:
  #
  #    Cypress::PopulationCloneJob.create(:subset_id => 'core20', :test_id => 'ID of vendor to which these patients belong')
  #
  #    Cypress::PopulationCloneJob.create(:patient_ids => [1,2,7,9,221], :test_id => 'ID of vendor to which these patients belong')
  # This will return a uuid which can be used to check in on the status of a job. More details on this can be found
  # at the {Resque Stats project page}[https://github.com/quirkey/resque-status].
  class PopulationCloneJob < Resque::JobWithStatus
    def perform
      # Clone AMA records from Mongo

      ama_patients = Record.where(:test_id => nil)
    
      if options['patient_ids']
        # clone each of the patients identified in the :patient_ids parameter
        ama_patients = Record.where(:test_id => nil).in(medical_record_number: options['patient_ids'])
      elsif options['subset_id'] != "all"
        # If we're using one of the predefined patient populations, use the patients identified therein
        patient_population = PatientPopulation.where(:name => options['subset_id']).first
        ama_patients = Record.in(medical_record_number: patient_population.patient_ids)
      else
        # For randomness, when a user requests to use the full test deck, we add up to 10% duplicate records
        #additional_patient_count = Random.rand(ama_patients.size * 0.1).to_i
        #additional_patient_ids = additional_patient_count.times.map{ Random.rand(ama_patients.size).to_s }
        #additional_patients = Record.where(:test_id => nil).where(:patient_id.in => additional_patient_ids)
        #ama_patients = ama_patients.concat(additional_patients)
      end
      
      rand_prefix = Time.new.to_i
      ama_patients.each_with_index do |patient, index|
        cloned_patient = patient.clone
        cloned_patient.medical_record_number = "#{rand_prefix}#{index}"
        cloned_patient.first = APP_CONFIG["randomization"]["names"]["first"][cloned_patient.gender].sample
        cloned_patient.last = APP_CONFIG["randomization"]["names"]["last"].sample
        cloned_patient.test_id = options['test_id']

        cloned_patient.save!
      end
    end
  end
end