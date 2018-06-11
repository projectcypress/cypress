# The Patient model is an extension of app/models/qdm/patient.rb as defined by CQM-Models.
Patient = QDM::Patient

module QDM
  class Patient
    def destroy
      calculation_results.destroy
      delete
    end

    def product_test
      ProductTest.where('_id' => extendedData[:correlation_id]).most_recent
    end

    def bundle
      if !self['bundleId'].nil?
        HealthDataStandards::CQM::Bundle.find(self['bundleId'])
      elsif !extendedData[:correlation_id].nil?
        ProductTest.find(extendedData[:correlation_id]).bundle
      end
    end

    def age_at(date)
      dob = Time.at(birthDatetime).in_time_zone
      date.year - dob.year - (date.month > dob.month || (date.month == dob.month && date.day >= dob.day) ? 0 : 1)
    end

    def original_patient
      if self['original_medical_record_number']
        bundle.patients.where('extendedData.medical_record_number' => self['original_medical_record_number']).first
      end
    end

    def calculation_results
      # TODO: CQL: update result model
      QDM::IndividualResult.where('patient_id' => id).where('IPP'.to_sym.gt => 0)
    end

    def duplicate_randomization(random: Random.new)
      patient = clone
      changed = { medical_record_number: medical_record_number, first: [first_names, first_names], last: [familyName, familyName] }
      patient, changed = randomize_patient_name_or_birth(patient, changed, random: random)
      randomize_demographics(patient, changed, random: random)
    end

    def provider
      return nil unless extendedData.provider_performances
      Provider.find(JSON.parse(extendedData.provider_performances).first['provider_id']['$oid'])
    end

    #
    # private
    #
    # TODO: R2P: use private keyword?
    def first_names
      givenNames.join(' ')
    end

    def randomize_patient_name_or_birth(patient, changed, random: Random.new)
      case random.rand(3) # random chooses which part of the patient is modified
      when 0 # first name
        patient = randomize_patient_name_first(patient, random: random)
        changed[:first] = [first_names, patient.first_names]
      when 1 # last name
        patient = randomize_patient_name_last(patient, random: random)
        changed[:last] = [familyName, patient.familyName]
      when 2 # birthdate
        patient.birthDatetime = DateTime.strptime(patient.birthDatetime.to_s, '%s').change(
          case random.rand(3)
          when 0 then { day: 1, month: 1 }
          when 1 then { day: random.rand(28) + 1 }
          when 2 then { month: random.rand(12) + 1 }
          end
        ).strftime('%s').to_i
        changed[:birthdate] = [birthDatetime, patient.birthDatetime]
      end
      [patient, changed]
    end

    def randomize_patient_name_first(patient, random: Random.new)
      case random.rand(3) # random chooses how to modify the field
      when 0 then patient.givenNames = [patient.givenNames[0][0]] # replace with only first initial
      when 1
        rand_idx = random.rand(patient.givenNames.count)
        patient.givenNames[rand_idx] = replace_random_char(patient.givenNames[rand_idx].clone, random: random) # insert incorrect letter
      when 2 # nickname
        givenNames.each_index do |idx|
          nicknames = NAMES_RANDOM['nicknames'][patient.gender][patient.givenNames[idx]]
          # if no nicknames, use first initial
          patient.givenNames[idx] = nicknames.blank? ? patient.givenNames[idx][0] : nicknames.sample(random: random)
        end
      end
      patient
    end

    def gender
      gender_chars = get_data_elements('patient_characteristic', 'gender')
      if gender_chars&.any? && gender_chars.first.dataElementCodes &&
         gender_chars.first.dataElementCodes.any?
        gender_chars.first.dataElementCodes.first['code']
      else
        raise 'Cannot find gender element'
      end
    end

    def randomize_patient_name_last(patient, random: Random.new)
      case random.rand(2)
      when 0 then patient.familyName = patient.familyName[0] # replace with initial
      when 1 then patient.familyName = replace_random_char(patient.familyName.clone, random: random) # insert incorrect letter
      end
      patient
    end

    def replace_random_char(name, random: Random.new)
      lowercases = ('a'..'z').to_a
      lsamples = lowercases.sample(2, random: random)
      name_pos = random.rand(name.length - 1) + 1
      name[name_pos] = name[name_pos] != lsamples[0] ? lsamples[0] : lsamples[1]
      name
    end

    def randomize_demographics(patient, changed, random: Random.new)
      # TODO: R2P: demographics from patient model
      [patient, changed, self]
    end

    #
    # HDS helpers
    #
  end
end
