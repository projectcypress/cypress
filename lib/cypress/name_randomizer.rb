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
          # if no nicknames, use first initial
          patient.givenNames[idx] = nicknames.blank? ? patient.givenNames[idx][0] : nicknames.sample(random: random)
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
  end
end
