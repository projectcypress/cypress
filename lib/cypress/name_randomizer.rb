module Cypress
  class NameRandomizer
    def self.randomize_patient_name_first(patient, augmented_patients, random: Random.new)
      original_given_name = patient.givenNames
      new_given_name = original_given_name.clone
      loop do
        case random.rand(3) # random chooses how to modify the field
        when 0 then new_given_name = [original_given_name[0][0]] # replace with only first initial
        when 1
          rand_idx = random.rand(original_given_name.count)
          new_given_name[rand_idx] = replace_random_char(original_given_name[rand_idx].clone, random: random) # insert incorrect letter
        when 2 # nickname
          original_given_name.each_index do |idx|
            nicknames = NAMES_RANDOM['nicknames'][patient.gender][original_given_name[idx]]
            patients = patient.product_test ? patient.product_test.patients : []
            new_given_name[idx] = safe_nickname(nicknames,
                                                original_given_name[idx],
                                                patient.familyName,
                                                patients,
                                                random: random)
          end
        end
        patient.givenNames = new_given_name unless augmented_patients.any? { |ap| ap[:first][1] == new_given_name && ap[:last][0] == patient.familyName }
        break if patient.givenNames != original_given_name
      end
      patient
    end

    def self.randomize_patient_name_last(patient, augmented_patients, random: Random.new)
      original_family_name = patient.familyName
      new_family_name = original_family_name.clone
      loop do
        case random.rand(2)
        when 0 then patient.familyName = patient.familyName[0] # replace with initial
        when 1 then patient.familyName = replace_random_char(patient.familyName.clone, random: random) # insert incorrect letter
        end
        patient.familyName = new_family_name unless augmented_patients.any? { |ap| ap[:last][1] == new_family_name && ap[:first][0] == patient.givenNames }
        break if patient.familyName != original_family_name
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
