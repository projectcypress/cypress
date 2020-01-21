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

      # grab a random number of patients and then randomize the dates between +- 10 days
      randomize_ids(patients, prng) if options['randomization_ids']

      # if Shift patients is selected, move all patient data into the actual reporting period
      if @test.product.shift_patients
        date_shift = @test.bundle.start_date_offset
        patients.each do |patient|
          patient.qdmPatient.shift_dates(date_shift)
        end
      end

      # get single provider if @test is a measure test. measure tests have a single provider for each patient while filtering tests can have different
      # providers for each patient
      provider = @test.provider if @test.class == MeasureTest

      patients.collect { |patient| clone_and_save_patient(patient, prng, provider, @test.product.allow_duplicate_names) }
    end

    def find_patients_to_clone
      # Clone AMA patients from Mongo
      @test = ProductTest.find(options['test_id'])
      if options['patient_ids']
        # clone each of the patients identified in the :patient_ids parameter
        CQM::Patient.find(options['patient_ids']).to_a
      else
        @test.bundle.patients.where(correlation_id: nil).to_a
      end
    end

    def randomize_ids(patients, prng)
      how_many = prng.rand(5) + 1
      randomization_ids = options['randomization_ids'].shuffle(random: prng)[0..how_many]
      random_patients = Patient.find(randomization_ids).to_a
      random_patients.each do |patient|
        plus_minus = prng.rand(2).zero? ? 1 : -1 # use this to make move dates forward or backwards
        date_shift = prng.rand(1_944_000) * plus_minus # 1_944_000 = 60 secs per min * 60 min per hour * 24 hours in day * 10 days
        patient.qdmPatient.shift_dates(date_shift)
        patients << patient
      end
    end

    # if provider argument is nil, this function will assign a new provider based on the @option['providers'] and @option['generate_provider'] options
    def clone_and_save_patient(patient, prng, provider = nil, allow_dups = false)
      # This operates on the assumption that we are always cloning a patient for a product test.
      # If we need to clone a patient for any other reason then we will need to paramaterize
      # the type coming into this class.
      cloned_patient = ProductTestPatient.new(patient.attributes.except(:_id, :_type, :providers))
      cloned_patient.attributes = {
        original_medical_record_number: patient.medical_record_number,
        original_patient_id: patient.id,
        correlation_id: options['test_id']
      }
      unnumerify cloned_patient if patient.givenNames.map { |n| n =~ /\d/ }.any? || patient.familyName =~ /\d/
      cloned_patient.medical_record_number = next_medical_record_number unless options['disable_randomization']
      @test.reload
      DemographicsRandomizer.set_default_demographics(cloned_patient)
      DemographicsRandomizer.randomize(cloned_patient, prng, @test.patients, allow_dups) if options['randomize_demographics']
      # work around to replace 'Other' race codes in Cypress bundle. Pass in static seed for consistent results.
      DemographicsRandomizer.randomize_race(cloned_patient, Random.new(0)) if cloned_patient.race == '2131-1'
      randomize_entry_ids(cloned_patient) unless options['disable_randomization']
      # if the test is a multi measure test, restrict to a single code
      restrict_entry_codes(cloned_patient) if @test.is_a? MultiMeasureTest
      provider ? assign_existing_provider(cloned_patient, provider) : assign_provider(cloned_patient)
      cloned_patient.save!
      cloned_patient
    end

    def unnumerify(patient)
      [%w[0 ZERO], %w[1 ONE], %w[2 TWO], %w[3 THREE], %w[4 FOUR], %w[5 FIVE], %w[6 SIX], %w[7 SEVEN], %w[8 EIGHT], %w[9 NINE]].each do |replacement|
        patient.givenNames.map { |n| n.gsub!(replacement[0], replacement[1]) }
        patient.familyName.gsub!(replacement[0], replacement[1])
      end
    end

    def restrict_entry_codes(cloned_patient)
      # Loop through every data element
      cloned_patient.qdmPatient.dataElements.each do |entry|
        next if entry.dataElementCodes.blank?

        # look up if the vendor has a preferred_code_system for the qdmCategory
        vendor_preference = @test.product.vendor.preferred_code_systems[entry.qdmCategory]
        # if the vendor does not have a preference, pick the first code
        if vendor_preference.blank?
          entry.dataElementCodes = [entry.dataElementCodes[0]]
        else
          # if the vendor has a preference, loop through in order
          vendor_preference.each do |vp|
            # find data element codes that match the preference
            pc = entry.dataElementCodes.map { |dec| dec if dec['system'] == vp }.compact
            # if none found, look for the next one
            next if pc.blank?

            # if found, set data element codes to the first code from the preferred code system
            entry.dataElementCodes = [pc[0]]
            # exit loop once found
            break
          end
        end
        # if there are still multiple codes, use the first
        entry.dataElementCodes = [entry.dataElementCodes[0]] if entry.dataElementCodes.size > 1
      end
    end

    def randomize_entry_ids(cloned_patient)
      entries_with_references = []
      entry_id_hash = {}
      index = 0
      cloned_patient.qdmPatient.dataElements.each do |entry|
        entry_id_hash[entry._id.to_s] = BSON::ObjectId.new
        entry._id = entry_id_hash[entry._id.to_s]
        entry.id = entry._id.to_s
        entries_with_references.push(index) unless entry['relatedTo'].nil?
        index += 1
      end
      cloned_patient.qdmPatient._id = BSON::ObjectId.new
      reconnect_references(cloned_patient, entries_with_references, entry_id_hash)
    end

    def reconnect_references(cloned_patient, entries_with_references, entry_id_hash)
      entries_with_references.each do |entry_with_reference_index|
        entry_with_reference = cloned_patient.qdmPatient.dataElements[entry_with_reference_index]
        references_to_add = []
        entry_with_reference.relatedTo.each do |ref|
          new_ref = entry_id_hash[ref].to_s
          references_to_add << new_ref
        end
        entry_with_reference.relatedTo = []
        references_to_add.each do |ref|
          entry_with_reference.relatedTo << ref
        end
      end
    end

    def next_medical_record_number
      @rand_prefix ||= @options['job_id']
      @rand_prefix ||= Time.new.to_i
      @current_index ||= 0
      @current_index += 1
      "#{@rand_prefix}_#{@current_index}"
    end

    def assign_provider(patient)
      prov = if @options['providers']
               @options['providers'].sample
             elsif @options['generate_provider']
               # limit the number of generated providers to 3
               generate_provider if @generated_providers.size < 3
               @generated_providers.sample
             else
               Provider.default_provider(measure_type: @test.measures.first.reporting_program_type)
             end
      patient.providers << prov
    end

    def generate_provider
      @generated_providers << Provider.generate_provider(measure_type: @test.measures.first.reporting_program_type)
    end

    def assign_existing_provider(patient, provider)
      patient.providers << provider
    end
  end
end
