module Cypress
  class NameRandomizer
    def self.randomize_patient_name_first(patient, augmented_patients, random: Random.new)
      original_gn = patient.givenNames
      new_gn = original_gn.clone
      loop do
        # Try to create a new random name
        new_gn = random_given_name(patient, original_gn, random: random)
        # Verify that the new random name, does not conflict with an existing Augmented Patient
        patient.givenNames = new_gn unless augmented_patients.any? { |ap| ap[:first][1] == new_gn[0] && ap[:last][0] == patient.familyName }
        # Break when a new unique name is found
        break if patient.givenNames != original_gn
      end
      patient
    end

    def self.random_given_name(patient, original_given_name, random: Random.new)
      updated_name = original_given_name.clone
      case random.rand(3) # random chooses how to modify the field
      when 0 then [updated_name[0][0]] # replace with only first initial
      when 1
        rand_idx = random.rand(updated_name.count)
        updated_name[rand_idx] = replace_random_char(updated_name[rand_idx].clone, random: random) # insert incorrect letter
        updated_name
      when 2 # nickname
        updated_name.each_index do |idx|
          nicknames = NAMES_RANDOM['nicknames'][patient.gender][updated_name[idx]]
          patients = patient.product_test ? patient.product_test.patients : []
          updated_name[idx] = safe_nickname(nicknames,
                                            updated_name[idx],
                                            patient.familyName,
                                            patients,
                                            random: random)
        end
        updated_name
      end
    end

    def self.randomize_patient_name_last(patient, augmented_patients, random: Random.new)
      original_fn = patient.familyName
      new_fn = original_fn.clone
      loop do
        # Try to create a new random name
        case random.rand(2)
        when 0 then patient.familyName = patient.familyName[0] # replace with initial
        when 1 then patient.familyName = replace_random_char(patient.familyName.clone, random: random) # insert incorrect letter
        end
        # Verify that the new random name, does not conflict with an existing Augmented Patient
        patient.familyName = new_fn unless augmented_patients.any? { |ap| ap[:last][1] == new_fn && ap[:first][0] == patient.givenNames }
        # Break when a new unique name is found
        break if patient.familyName != original_fn
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
