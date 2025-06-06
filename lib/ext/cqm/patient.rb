# frozen_string_literal: true

# The Patient model is an extension of app/models/qdm/patient.rb as defined by CQM-Models.

module CQM
  class Patient
    include Mongoid::Timestamps
    field :correlation_id, type: BSON::ObjectId
    field :original_patient_id, type: BSON::ObjectId
    field :original_medical_record_number, type: String
    field :medical_record_number, type: String
    field :medicare_beneficiary_identifier, type: String, default: nil
    field :email, type: String, default: nil
    field :measure_relevance_hash, type: Hash, default: {}
    field :code_description_hash, type: Hash, default: {} # may contain extra code descriptions for original codes
    field :reported_measure_hqmf_ids, type: Array, default: []
    embeds_many :addresses # patient addresses
    embeds_many :telecoms

    # These are for CVU+
    field :file_name, type: String
    field :codes_modifiers, type: Hash

    # This allows us to instantiate Patients that do not belong to specific type of patient
    # for the purposes of testing but blocks us from saving them to the database to ensure
    # every patient actually in the database is of a valid type.
    validates :_type, inclusion: %w[CQM::BundlePatient CQM::VendorPatient CQM::ProductTestPatient CQM::TestExecutionPatient]

    before_save :account_for_epoch_time_zero

    after_initialize do
      self[:addresses] ||= [CQM::Address.new(
        use: 'HP',
        street: ['202 Burlington Rd.'],
        city: 'Bedford',
        state: 'MA',
        zip: '01730',
        country: 'US'
      )]
      self[:telecoms] ||= [CQM::Telecom.new(
        use: 'HP',
        value: '555-555-2003'
      )]
    end

    def destroy
      calculation_results.destroy
      delete
    end

    def product_test
      ProductTest.where('_id' => correlation_id).most_recent
    end

    def bundle
      if !self['bundleId'].nil?
        Bundle.find(self['bundleId'])
      elsif self['_type'] == 'CQM::TestExecutionPatient'
        TestExecution.find(correlation_id).task.bundle
      elsif self['_type'] == 'CQM::ProductTestPatient'
        ProductTest.find(correlation_id).bundle
      else
        Bundle.find_by(version: Settings.current.default_bundle)
      end
    end

    def age_at(date)
      dob = Time.at(qdmPatient.birthDatetime).in_time_zone
      date.year - dob.year - (date.month > dob.month || (date.month == dob.month && date.day >= dob.day) ? 0 : 1)
    end

    def original_patient
      Patient.find(original_patient_id) if original_patient_id
    end

    def lookup_provider(include_address = nil)
      # find with provider id hash i.e. "$oid"->value
      provider = providers.first
      addresses = provider.addresses.map do |address|
        { 'street' => address.street, 'city' => address.city, 'state' => address.state, 'zip' => address.zip,
          'country' => address.country }
      end

      return { 'npis' => [provider.npi], 'tins' => [provider.tin], 'addresses' => addresses } if include_address

      { 'npis' => [provider.npi], 'tins' => [provider.tin] }
    end

    def duplicate_randomization(augmented_patients, random: Random.new)
      patient = clone
      changed = { original_patient_id: id, first: [first_names, first_names], last: [familyName, familyName] }
      patient, changed = randomize_patient_name_or_birth(patient, changed, augmented_patients, random:)
      randomize_demographics(patient, changed, random:)
    end

    #
    # private
    #
    # TODO: R2P: use private keyword?
    def first_names
      givenNames.join(' ')
    end

    def randomize_patient_name_or_birth(patient, changed, augmented_patients, random: Random.new)
      case random.rand(21) # random chooses which part of the patient is modified. Limit birthdate to ~1/20
      when 0..9 # first name
        patient = Cypress::NameRandomizer.randomize_patient_name_first(patient, augmented_patients, random:)
        changed[:first] = [first_names, patient.first_names]
      when 10..19 # last name
        patient = Cypress::NameRandomizer.randomize_patient_name_last(patient, augmented_patients, random:)
        changed[:last] = [familyName, patient.familyName]
      when 20 # birthdate
        Cypress::DemographicsRandomizer.randomize_birthdate(patient.qdmPatient, random:)
        changed[:birthdate] = [qdmPatient.birthDatetime, patient.qdmPatient.birthDatetime]
      end
      [patient, changed]
    end

    def payer
      payer_element = qdmPatient.get_data_elements('patient_characteristic', 'payer')
      return unless payer_element&.any? && payer_element.first.dataElementCodes&.any?

      payer_element.first.dataElementCodes.first['code']
    end

    def gender
      gender_chars = qdmPatient.get_data_elements('patient_characteristic', 'gender')
      return unless gender_chars&.any? && gender_chars.first.dataElementCodes&.any?

      gender_chars.first.dataElementCodes.first['code']
    end

    def race
      race_element = qdmPatient.get_data_elements('patient_characteristic', 'race')
      return unless race_element&.any? && race_element.first.dataElementCodes&.any?

      race_element.first.dataElementCodes.first['code']
    end

    def ethnicity
      ethnicity_element = qdmPatient.get_data_elements('patient_characteristic', 'ethnicity')
      return unless ethnicity_element&.any? && ethnicity_element.first.dataElementCodes&.any?

      ethnicity_element.first.dataElementCodes.first['code']
    end

    # Iterates through each data element to add
    # 1. A Relevant DateTime if a Relevant Period is specified
    # 2. A Relevant Period if a Relevant DateTime is specified
    # This is used to normalize for eCQM calculations that may use one or the other
    # The denormalize_as_datetime flag is used by the "denormalize_date_times" to return the record to the original state
    def normalize_date_times(cms_id = nil)
      # normalization is only necessary for the 2020 bundles
      return unless normalize?(cms_id)

      qdmPatient.dataElements.each do |de|
        next unless de.respond_to?(:relevantDatetime) && de.respond_to?(:relevantPeriod)

        if de.relevantDatetime
          de.relevantPeriod = QDM::Interval.new(de.relevantDatetime, de.relevantDatetime).shift_dates(0)
          de.denormalize_as_datetime = true
        elsif de.relevantPeriod
          # if low time exists, use it.  Otherwise high time
          de.relevantDatetime = de.relevantPeriod.low || de.relevantPeriod.high
          de.denormalize_as_datetime = false
        end
      end
    end

    # "normalize_date_times" add a flag "denormalize_as_datetime" to indicate if a dataElement originally used relevantDatetime
    # using that flag, return record to the original state
    def denormalize_date_times(cms_id = nil)
      # normalization is only necessary for the 2020 bundles
      return unless normalize?(cms_id)

      qdmPatient.dataElements.each do |de|
        next unless de.respond_to?(:relevantDatetime) && de.respond_to?(:relevantPeriod)

        if de.denormalize_as_datetime
          de.relevantPeriod = nil
        else
          de.relevantDatetime = nil
        end
      end
      save
    end

    # when laboratory_tests and physical_exams are reported for CMS529, they need to reference the
    # encounter they are related to.  The time range can include 24 hours before and after the encounter occurs.
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def add_encounter_ids_to_events
      encounter_times = {}
      qdmPatient.get_data_elements('encounter', 'performed').each do |ep|
        # Only use inpatient encounter
        unless ep.dataElementCodes.map(&:code).intersect?(bundle.value_sets.where(oid: '2.16.840.1.113883.3.666.5.307').first.concepts.map(&:code))
          next
        end

        rel_time = ep.relevantPeriod
        # 1 day before and 1 day after
        rel_time.low -= 86_400
        rel_time.high += 86_400
        encounter_times[ep.id] = rel_time
      end
      qdmPatient.get_data_elements('laboratory_test', 'performed').each do |lt|
        event_time = lt.resultDatetime || lt.relevantDatetime || lt.relevantPeriod&.low
        lt.encounter_id = encounter_id_for_event(encounter_times, event_time)
        lt.relatedTo << lt.encounter_id if lt.encounter_id
      end
      qdmPatient.get_data_elements('physical_exam', 'performed').each do |pe|
        event_time = pe.relevantDatetime || pe.relevantPeriod&.low
        pe.encounter_id = encounter_id_for_event(encounter_times, event_time)
        pe.relatedTo << pe.encounter_id if pe.encounter_id
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def encounter_id_for_event(encounter_time_hash, event_time)
      encounter_time_hash.each do |e_id, range|
        return e_id if (event_time > range.low) && (event_time < range.high)
      end
      nil
    end

    def randomize_demographics(patient, changed, random: Random.new)
      case random.rand(3) # now, randomize demographics
      when 0 # gender
        Cypress::DemographicsRandomizer.randomize_gender(patient, random)
        changed[:gender] = [gender, patient.gender]
      when 1 # race
        Cypress::DemographicsRandomizer.randomize_race(patient, random)
        changed[:race] = [race, patient.race]
      when 2 # ethnicity
        Cypress::DemographicsRandomizer.randomize_ethnicity(patient, random)
        changed[:ethnicity] = [ethnicity, patient.ethnicity]
      end
      [patient, changed, self]
    end

    # A method for storing if a patient is relevant to a specific measure.  This method iterates through a set
    # of individal results and flags a patient as relevant if they calculate into the measures population
    # rubocop:disable Metrics/PerceivedComplexity
    def update_measure_relevance_hash(individual_result)
      ir = individual_result
      measure = CQM::Measure.only(:hqmf_id, :population_sets).find(ir.measure_id)
      # Create a new hash for a measure, if one doesn't already exist
      measure_relevance_hash[measure.id.to_s] = {} unless measure_relevance_hash[measure.id.to_s]
      if APP_CONSTANTS['result_measures'].map(&:hqmf_id).include?(measure.hqmf_id)
        update_ccde_measure_relevance(measure, ir)
      else
        # Iterate through each population for a measure
        measure.population_keys.each do |pop_key|
          # A patient is only relevant to the MSRPOPL if they are not also into the MSRPOPLEX
          # MSRPOPL is the only population that has an additional requirement for 'relevance'
          # Otherwise, if there is a count for the population, the relevance can be set to true
          if pop_key == 'MSRPOPL'
            measure_relevance_hash[measure.id.to_s]['MSRPOPL'] = true if (ir['MSRPOPL'].to_i - ir['MSRPOPLEX'].to_i).positive?
            measure_relevance_hash[measure.id.to_s]['OBSERV'] = true if ir['observation_values'].any?(&:positive?)
          elsif ir[pop_key].to_i.positive?
            measure_relevance_hash[measure.id.to_s][pop_key] = true
          end
        end
        measure_relevance_hash[measure.id.to_s]['IPPEX'] = true if ir['IPP'].to_i.zero? && measure.individual_result_relevant_to_measure(ir)
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity

    def update_ccde_measure_relevance(measure, individual_result)
      statement_name = APP_CONSTANTS['result_measures'].select { |rm| rm['hqmf_id'] == measure.hqmf_id }.first['statement_name']
      statement_results = individual_result.statement_results.select { |sr| sr['statement_name'] == statement_name }.first['raw']
      measure_relevance_hash[measure.id.to_s]['IPP'] = true if statement_results.any? { |_key, value| !value.empty? && value.first['FirstResult'] }
    end

    # Return true if the patient is relevant for one of the population keys in one of the measures passed in
    def patient_relevant?(measure_ids, population_keys)
      measure_relevance_hash.any? do |measure_key, mrh|
        # Does the list of measure include the key from the measure relevance hash, and
        # Does the measure relevance include a true value from on of the requested population keys.
        (measure_ids.include? BSON::ObjectId.from_string(measure_key)) && (population_keys.any? { |pop| mrh[pop] == true })
      end
    end

    def remove_telehealth_codes(ineligible_measures)
      warnings = []
      Cypress::QrdaPostProcessor.remove_telehealth_encounters(self, codes_modifiers, warnings, ineligible_measures) unless codes_modifiers.empty?
      save
      warnings
    end

    # This method removes negations that are not for the oids provided
    # The negations are not acutally removed, the replacement codes are modified so they will not
    # factor in calcuations
    def nullify_unnessissary_negations(valueset_oids)
      qdmPatient.dataElements.each do |de|
        negated_vs = de.dataElementCodes.select { |dec| dec.system == '1.2.3.4.5.6.7.8.9.10' }
        next if negated_vs.blank?

        de.dataElementCodes.each do |dec|
          break if valueset_oids.include?(negated_vs.first.code)
          next if dec.system == '1.2.3.4.5.6.7.8.9.10'

          dec.system.concat('NA')
        end
      end
    end

    # Revert the dataElement that had be modified by the nullify_unnessissary_negations method
    def reestablish_negations
      qdmPatient.dataElements.each do |de|
        negated_vs = de.dataElementCodes.select { |dec| dec.system == '1.2.3.4.5.6.7.8.9.10' }
        next if negated_vs.blank?

        de.dataElementCodes.each do |dec|
          next if dec.system == '1.2.3.4.5.6.7.8.9.10'

          dec.system.delete_suffix!('NA')
        end
      end
    end

    # options and cms_id comes from the SingleMeasureCalculationJob
    def check_for_elements_after_mp(options, cms_id)
      mp_end = (DateTime.parse(options[:effectiveDate]) + 1.year - 1.second).to_i
      qdmPatient.dataElements.each do |data_element|
        occurs_after, de_date_time = data_element.occurs_after_date?(mp_end)
        # move on unless date is beyond the measurement period
        next unless occurs_after

        # Adding NA to the codesystem will effectively remove the element for calcuation, and allows it to be easily rerturned for other calculations
        data_element.dataElementCodes.each do |dec|
          dec.system.concat('NA')
        end

        # If the patient is a TestExecutionPatient (for CMS Program Tests) add a warning message
        next unless is_a? CQM::TestExecutionPatient

        te = TestExecution.find(correlation_id)
        msg = "#{data_element._type} that occurs after the Performance Period on #{de_date_time.strftime('%m/%d/%Y')} " \
              "was not used in calculation for #{cms_id}."
        te.execution_errors.build(message: msg, msg_type: :warning, file_name:)
        te.save
      end
    end

    def reestablish_elements_after_mp
      qdmPatient.dataElements.each do |data_element|
        # Removing NA from the codesystem will allow element to be used for calculation again
        data_element.dataElementCodes.each do |dec|
          dec.system.delete_suffix!('NA')
        end
      end
    end

    # Birthdate times at the epoch time boundary throws off the cql-calculation engine, workaround to add 1 second to the birthtime.
    def account_for_epoch_time_zero
      return unless qdmPatient.birthDatetime
      return unless qdmPatient.birthDatetime.to_i.zero?

      qdmPatient.birthDatetime = qdmPatient.birthDatetime.change(sec: 1)
      return unless qdmPatient.dataElements.where(_type: QDM::PatientCharacteristicBirthdate).first

      qdmPatient.dataElements.where(_type: QDM::PatientCharacteristicBirthdate).first.birthDatetime = qdmPatient.birthDatetime
    end

    def normalize?(cms_id = '')
      return true if bundle&.major_version == '2020'

      true if cms_id == 'CMS1154v1'
    end
  end

  class BundlePatient < Patient; end

  class VendorPatient < Patient; end

  class ProductTestPatient < Patient; end

  class TestExecutionPatient < Patient; end
end

Patient = CQM::Patient
BundlePatient = CQM::BundlePatient
VendorPatient = CQM::VendorPatient
ProductTestPatient = CQM::ProductTestPatient
TestExecutionPatient = CQM::TestExecutionPatient
