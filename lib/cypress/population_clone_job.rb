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
      @test = ProductTest.find(options["test_id"])
      patients=[]
      if options['patient_ids']
        # clone each of the patients identified in the :patient_ids parameter
        patients = @test.bundle.records.where(:test_id => nil).in(medical_record_number: options['patient_ids']).to_a
      else
        patients = @test.bundle.records.where(:test_id => nil).to_a
      end

      # grab a random number of records and then randomize the dates between +- 10 days
      if options["randomization_ids"]
        how_many = rand(5) + 1
        randomization_ids = options["randomization_ids"].shuffle[0..how_many]
        random_records = @test.bundle.records.where(:test_id => nil).in(medical_record_number: randomization_ids).to_a

        random_records.each do |patient|
          seconds = 60*60*24*10 # secs per min * min per hour * hours in day * 10 days
          plus_minus = rand(2) == 0 ? 1 : -1 # use this to make move dates forward or backwards
          date_shift = rand(seconds) * plus_minus
          patient.shift_dates(date_shift)
          patients << patient 
        end
      end

      patients.each do |patient|
        clone_and_save_record(patient)
      end

    end


    def clone_and_save_record(record,  date_shift=nil)
        cloned_patient = record.clone
        cloned_patient[:original_medical_record_number] = cloned_patient.medical_record_number 
        cloned_patient.medical_record_number = next_medical_record_number
        randomize_name(cloned_patient) if options['randomize_names']
        cloned_patient.shift_dates(date_shift) if date_shift
        cloned_patient.test_id = options['test_id']
        patch_insurance_provider(record)
        cloned_patient.entries.each do |entry|
          entry.id = Moped::BSON::ObjectId.new
        end
        cloned_patient.save!
    end

    def randomize_name(record)
      @used_names ||= {}
      @used_names[record.gender] ||= []
      begin 
        record.first = APP_CONFIG["randomization"]["names"]["first"][record.gender].sample
        record.last = APP_CONFIG["randomization"]["names"]["last"].sample
      end while(@used_names[record.gender].find("#{record.first}-#{record.last}").nil?)  
      @used_names[record.gender] << "#{record.first}-#{record.last}"
    end



    def next_medical_record_number
      @rand_prefix ||= Time.new.to_i
      @current_index ||= 0
      @current_index += 1
       "#{@rand_prefix}_#{@current_index}"
    end


     def patch_insurance_provider(patient)
      insurance_codes = {
      'MA' => '1',
      'MC' => '2',
      'OT' => '349'
      }
      patient.insurance_providers.each do |ip|
        if ip.codes.empty?
          ip.codes["SOP"] = [insurance_codes[ip.type]]
        end
      end

    end

  end

end