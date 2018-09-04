module Cypress
  # This is Resque job that will create patients for a ProductTest. Currently you have the choice between doing a full
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

      %w[randomize_demographics generate_provider randomization_ids].each { |k| @options.delete k } if @options['disable_randomization']

      @generated_providers = [] if @options['generate_provider']
    end

    def perform
      # Clone AMA patients from Mongo
      patients = find_patients_to_clone

      prng = Random.new(@test.rand_seed.to_i)

      # if Shift patients is selected, move all patient data into the actual reporting period
      if @test.product.shift_patients
        date_shift = @test.bundle.start_date_offset
        patients.each do |patient|
          patient.shift_dates(date_shift)
        end
      end
      # grab a random number of patients and then randomize the dates between +- 10 days
      randomize_ids(patients, prng) if options['randomization_ids']

      # get single provider if @test is a measure test. measure tests have a single provider for each patient while filtering tests can have different
      # providers for each patient
      provider = @test.provider if @test.class == MeasureTest

      allow_dups = @test.product.allow_duplicate_names

      patients.each { |patient| clone_and_save_patient(patient, prng, provider, allow_dups) }
    end

    def find_patients_to_clone
      # Clone AMA patients from Mongo
      @test = ProductTest.find(options['test_id'])
      if options['patient_ids']
        # clone each of the patients identified in the :patient_ids parameter
        @test.bundle.patients.find(options['patient_ids']).to_a
      else
        @test.bundle.patients.where('extendedData.correlation_id': nil).to_a
      end
    end

    def randomize_ids(patients, prng)
      how_many = prng.rand(5) + 1
      randomization_ids = options['randomization_ids'].shuffle(random: prng)[0..how_many]
      random_patients = @test.bundle.patients.find(randomization_ids).to_a

      random_patients.each do |patient|
        seconds = 1_944_000 # 60 secs per min * 60 min per hour * 24 hours in day * 10 days
        plus_minus = prng.rand(2).zero? ? 1 : -1 # use this to make move dates forward or backwards
        date_shift = prng.rand(seconds) * plus_minus
        patient.shift_dates(date_shift)
        patients << patient
      end
    end

    # if provider argument is nil, this function will assign a new provider based on the @option['providers'] and @option['generate_provider'] options
    def clone_and_save_patient(patient, prng, provider = nil, allow_dups = false)
      cloned_patient = patient.clone
      # TODO: R2P: use patient model
      unnumerify cloned_patient if patient.givenNames.map { |n| n =~ /\d/ }.any? || patient.familyName =~ /\d/
      cloned_patient[:original_medical_record_number] = cloned_patient.extendedData[:medical_record_number]
      cloned_patient.extendedData[:original_patient] = patient.id
      cloned_patient.extendedData[:medical_record_number] = next_medical_record_number unless options['disable_randomization']
      DemographicsRandomizer.randomize(cloned_patient, prng, allow_dups) if options['randomize_demographics']
      cloned_patient.extendedData[:correlation_id] = options['test_id']
      patch_insurance_provider(patient)
      randomize_entry_ids(cloned_patient) unless options['disable_randomization']
      # assign existing provider if provider argument is not nil (should be when @test is a measure test)
      provider ? assign_existing_provider(cloned_patient, provider) : assign_provider(cloned_patient)
      cloned_patient.save!
    end

    def unnumerify(patient)
      [%w[0 ZERO], %w[1 ONE], %w[2 TWO], %w[3 THREE], %w[4 FOUR], %w[5 FIVE], %w[6 SIX], %w[7 SEVEN], %w[8 EIGHT], %w[9 NINE]].each do |replacement|
        patient.givenNames.map { |n| n.gsub!(replacement[0], replacement[1]) }
        patient.familyName.gsub!(replacement[0], replacement[1])
      end
    end

    def randomize_entry_ids(cloned_patient)
      entries_with_references = []
      entry_id_hash = {}
      index = 0
      cloned_patient.dataElements.each do |entry|
        entry_id_hash[entry._id.to_s] = BSON::ObjectId.new
        entry._id = entry_id_hash[entry._id.to_s]
        entry.id = QDM::Id.new(value: entry._id)
        entries_with_references.push(index) unless entry['relatedTo'].nil?
        index += 1
      end
      reconnect_references(cloned_patient, entries_with_references, entry_id_hash)
    end

    def reconnect_references(cloned_patient, entries_with_references, entry_id_hash)
      entries_with_references.each do |entry_with_reference_index|
        entry_with_reference = cloned_patient.dataElements[entry_with_reference_index]
        entry_with_reference.relatedTo.map! { |ref| entry_id_hash[ref.to_s] }.compact!
      end
    end

    def next_medical_record_number
      @rand_prefix ||= @options['job_id']
      @rand_prefix ||= Time.new.to_i
      @current_index ||= 0
      @current_index += 1
      "#{@rand_prefix}_#{@current_index}"
    end

    def patch_insurance_provider(patient)
      insurance_codes = { 'MA' => '1', 'MC' => '2', 'OT' => '349' }
      providers = JSON.parse(patient.extendedData['insurance_providers'])
      providers.each { |ip| ip.codes['SOP'] = [insurance_codes[ip.type]] if ip.codes.empty? }
      patient.extendedData['insurance_providers'] = JSON.generate(providers)
    end

    def assign_provider(patient)
      prov = if @options['providers']
               @options['providers'].sample
             elsif @options['generate_provider']
               # limit the number of generated providers to 3
               generate_provider if @generated_providers.size < 3
               @generated_providers.sample
             else
               measure = @test.measures.first
               Provider.default_provider(measure_type: measure.type)
             end
      patient.extendedData['provider_performances'] = JSON.generate([{ provider_id: prov.id }]) if prov
    end

    def generate_provider
      @generated_providers << Provider.generate_provider(measure_type: @test.measures.first.type)
    end

    def assign_existing_provider(patient, provider)
      patient.extendedData['provider_performances'] = JSON.generate([{ provider_id: provider.id }])
    end
  end
end
