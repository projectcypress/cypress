module Cypress
  class NameRandomizer
    def self.randomize_patient_name_first(patient, random: Random.new)
      case random.rand(3) # random chooses how to modify the field
      when 0 then patient.givenNames = [patient.givenNames[0][0]] # replace with only first initial
      when 1
        rand_idx = random.rand(patient.givenNames.count)
        patient.givenNames[rand_idx] = replace_random_char(patient.givenNames[rand_idx].clone, random: random) # insert incorrect letter
      when 2 # nickname
        patient.givenNames.each_index do |idx|
          nicknames = NAMES_RANDOM['nicknames'][patient.gender][patient.givenNames[idx]]
          patient.givenNames[idx] = safe_nickname(nicknames,
                                                  patient.givenNames[idx],
                                                  patient.familyName,
                                                  patient.product_test.patients,
                                                  random: random)
        end
      end
      patient
    end

    def self.randomize_patient_name_last(patient, random: Random.new)
      case random.rand(2)
      when 0 then patient.familyName = patient.familyName[0] # replace with initial
      when 1 then patient.familyName = replace_random_char(patient.familyName.clone, random: random) # insert incorrect letter
      end
      patient
    end

    def self.replace_random_char(name, random: Random.new)
      lowercases = ('a'..'z').to_a
      lsamples = lowercases.sample(2, random: random)
      name_pos = random.rand(name.length - 1) + 1
      name[name_pos] = name[name_pos] != lsamples[0] ? lsamples[0] : lsamples[1]
      name
    end

    def self.safe_nickname(nicknames, given_name, family_name, patients, random: Random.new)
      # if no nicknames, use first initial
      return given_name[0] if nicknames.blank?
      nickname = nicknames.sample(random: random)
      # if nickname collides with a name in the patient list, use first initial
      patients.none? { |p| "#{p.first_names}-#{p.familyName}" == "#{nickname}-#{family_name}" } ? nickname : given_name[0]
    end
  end
end
