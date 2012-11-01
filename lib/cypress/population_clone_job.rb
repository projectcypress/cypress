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
  class PopulationCloneJob

    attr_reader :options

    def initialize(options)
      @options = options
    end
    
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

        if options["randomize_names"]
          cloned_patient.first = APP_CONFIG["randomization"]["names"]["first"][cloned_patient.gender].sample
          cloned_patient.last = APP_CONFIG["randomization"]["names"]["last"].sample
        end
        cloned_patient.test_id = options['test_id']

        cloned_patient.save!
      end
    end
  end


  class QRDAGenerationJob

    attr_accessor :options
    def initialize(options)
      @options = options
    end

    def perform
      test_id = options["test_id"]
      test = ProductTest.find(test_id)
      patient_needs = {test.id => []}
      all_value_sets = {test.id => []}

      # This reshapes NLM value sets to the imported value sets that the Test Patient Generator expects from Bonnie. 
      # TODO Just pass the NLM value sets to the generator once Bonnie is refactored to also use the NLM.
      oids = test.measures.map{|measure| measure.oids}.flatten.uniq
      HealthDataStandards::SVS::ValueSet.any_in(oid: oids).each do |value_set|
        code_sets = value_set.concepts.map {|concept| {"code_set" => concept.code_system_name, "codes" => [concept.code]}}
        all_value_sets[test.id] << {"code_sets" => code_sets, "oid" => value_set.oid}
      end

      test.measures.top_level.each do |measure|
        puts "Gathering data criteria from #{measure.nqf_id}"
        patient_needs[test.id] << measure.data_criteria.map{|dc| HQMF::DataCriteria.from_json(dc.keys.first, dc.values.first)}
      end
      patient_needs[test.id].flatten!
      patient_needs[test.id].uniq!

      patients = HQMF::Generator.generate_qrda_patients(patient_needs, all_value_sets)
      patients.each do |measure, patient|
        patient.test_id = test.id
        patient.save
      end
      
      test.ready

    end

  end


end