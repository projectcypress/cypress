module Cypress
  class NameRandomizer
    def self.randomize_patient_name_first(patient, augmented_patients, random: Random.new)
      patients = patient.product_test ? patient.product_test.patients : []
      original_given_name = patient.givenNames
      loop do
        # Each time, start with original name
        new_given_name = original_given_name.clone
        # Try to create a new random name
        new_given_name = random_given_name(patient, new_given_name, random: random)
        # Verify that the new random name, does not conflict with an existing Augmented Patient
        patient.givenNames = new_given_name if name_unique?(new_given_name, patient.familyName, patients, augmented_patients)
        # Break when a new unique name is found
        break if patient.givenNames != original_given_name
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
          updated_name[idx] = nickname(nicknames, updated_name[idx], random: random)
        end
        updated_name
      end
    end

    def self.randomize_patient_name_last(patient, augmented_patients, random: Random.new)
      patients = patient.product_test ? patient.product_test.patients : []
      original_family_name = patient.familyName
      loop do
        # Each time, start with original name
        new_family_name = original_family_name.clone
        # Try to create a new random name
        case random.rand(2)
        when 0 then new_family_name = patient.familyName[0] # replace with initial
        when 1 then new_family_name = replace_random_char(new_family_name, random: random) # insert incorrect letter
        end
        # Verify that the new random name, does not conflict with an existing Augmented Patient
        patient.familyName = new_family_name if name_unique?(patient.givenNames, new_family_name, patients, augmented_patients)
        # Break when a new unique name is found
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

    def self.nickname(nicknames, given_name, random: Random.new)
      # if no nicknames, use first initial
      return given_name[0] if nicknames.blank?

      nicknames.sample(random: random)
    end

    def self.name_unique?(new_given_names, new_family_name, patients, augmented_patients)
      new_given_names = new_given_names.join(' ')
      # does name collide with a name in the patient list
      conflicting_patient = patients.any? { |p| "#{p.first_names}-#{p.familyName}" == "#{new_given_names}-#{new_family_name}" }
      # does name collide with a name in the augmented patients list
      conflicting_augmented_patient = augmented_patients.any? { |ap| ap[:first][1] == new_given_names && ap[:last][1] == new_family_name }
      !(conflicting_patient || conflicting_augmented_patient)
    end
  end
end
