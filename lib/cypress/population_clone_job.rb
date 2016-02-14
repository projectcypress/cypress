module Cypress
  # This is Resque job that will create records for a ProductTest. Currently you have the choice between doing a full
  # clone of the test deck or a specific subset to cover the 3 core measures. In the near future we will support more
  # options to make very customized TD subsets. For now, a subset_id of 'core20' will mean the 3 core measures. If that
  # parameter does not exist, we copy the whole deck. For example:
  #
  #    Cypress::PopulationCloneJob.new('subset_id' => 'core20',
  #                                    'test_id' => 'ID of vendor to which these patients belong')
  #
  #    Cypress::PopulationCloneJob.new('patient_ids' => [1,2,7,9,221],
  #                                    'test_id' => 'ID of vendor to which these patients belong')
  #
  # This will return a uuid which can be used to check in on the status of a job. More details on this can be found
  # at the {Resque Stats project page}[https://github.com/quirkey/resque-status].
  class PopulationCloneJob
    attr_reader :options

    def initialize(options)
      @options = options

      if @options['disable_randomization']
        %w(randomize_demographics generate_provider randomization_ids).each { |k| @options.delete k }
      end
    end

    def perform
      # Clone AMA records from Mongo
      patients = find_patients_to_clone

      # grab a random number of records and then randomize the dates between +- 10 days
      randomize_ids patients if options['randomization_ids']

      patients.each do |patient|
        clone_and_save_record(patient)
      end
    end

    def find_patients_to_clone
      # Clone AMA records from Mongo
      @test = ProductTest.find(options['test_id'])
      patients = if options['patient_ids']
                   # clone each of the patients identified in the :patient_ids parameter
                   @test.bundle.records.where(test_id: nil).in(medical_record_number: options['patient_ids']).to_a
                 else
                   @test.bundle.records.where(test_id: nil).to_a
                 end
      patients
    end

    def randomize_ids(patients)
      how_many = rand(5) + 1
      randomization_ids = options['randomization_ids'].shuffle[0..how_many]
      random_records = @test.bundle.records.where(test_id: nil).in(medical_record_number: randomization_ids).to_a

      random_records.each do |patient|
        seconds = 1_944_000 # 60 secs per min * 60 min per hour * 24 hours in day * 10 days
        plus_minus = rand(2) == 0 ? 1 : -1 # use this to make move dates forward or backwards
        date_shift = rand(seconds) * plus_minus
        patient.shift_dates(date_shift)
        patients << patient
      end
    end

    def clone_and_save_record(record, date_shift = nil)
      cloned_patient = record.clone
      cloned_patient[:original_medical_record_number] = cloned_patient.medical_record_number
      cloned_patient.medical_record_number = next_medical_record_number unless options['disable_randomization']
      DemographicsRandomizer.randomize(cloned_patient) if options['randomize_demographics']
      cloned_patient.shift_dates(date_shift) if date_shift
      cloned_patient.test_id = options['test_id']
      patch_insurance_provider(record)
      randomize_entry_ids(cloned_patient) unless options['disable_randomization']
      assign_provider(cloned_patient)
      cloned_patient.save!
    end

    def randomize_entry_ids(cloned_patient)
      entries_with_references = []
      entry_id_hash = {}
      index = 0
      cloned_patient.entries.each do |entry|
        entry_id_hash[entry.id.to_s] = BSON::ObjectId.new
        entry.id = entry_id_hash[entry.id.to_s]
        entries_with_references.push(index) unless entry['references'].nil?
        index += 1
      end
      reconnect_references(cloned_patient, entries_with_references, entry_id_hash)
    end

    def reconnect_references(cloned_patient, entries_with_references, entry_id_hash)
      entries_with_references.each do |entry_with_reference_index|
        entry_with_reference = cloned_patient.entries[entry_with_reference_index]
        entry_with_reference.references.each do |reference|
          old_id = reference['referenced_id']
          reference['referenced_id'] = entry_id_hash[old_id].to_s
        end
      end
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
        ip.codes['SOP'] = [insurance_codes[ip.type]] if ip.codes.empty?
      end
    end

    def assign_provider(patient)
      prov = if @options['providers']
               @options['providers'].sample
             elsif @options['generate_provider']
               generate_provider
             else
               Provider.default_provider
             end
      patient.provider_performances.build(provider: prov) if prov
    end

    def generate_provider
      @prov ||= Provider.generate_provider
      @prov
    end
  end
end
