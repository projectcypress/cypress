module Cypress
  class ClinicalRandomizer
    def self.randomize(patient, effective_date, measure_period_start, random: Random.new)
      case random.rand(2)
      when 0
        split_by_date(patient, effective_date, measure_period_start, random)
      when 1
        split_by_type(patient, effective_date, measure_period_start, random)
      end
    end

    def self.split_by_date(patient, effective_date, measure_period_start, random)
      patient_char_de = patient.get_data_elements('patient_characteristic')
      patient1 = patient.clone
      patient2 = patient.clone

      # Find a date that splits the data_elements such that at least 1 is in each patient
      split_date = find_split_date(patient, effective_date, measure_period_start, random)

      # Sort the data_elements from earliest to latest so we can split them more easily
      data_elements = sort_by_start_time(patient.dataElements)

      if split_date
        patient1, patient2 = set_data_elements(data_elements, patient1, patient2, split_date)
      else
        # set all patient1 data elements
        patient1.dataElements = data_elements
        patient2.dataElements = []
      end
      patient1.dataElements.concat patient_char_de
      patient2.dataElements.concat patient_char_de
      patient.dataElements.concat patient_char_de

      [patient1, patient2]
    end

    def self.set_data_elements(data_elements, patient1, patient2, split_date)
      patient1.dataElements = []
      patient2.dataElements = []
      data_elements.take_while { |de| de_before_split_date(de, split_date) }.each do |de|
        patient1.dataElements.push de
      end
      data_elements.drop_while { |de| de_before_split_date(de, split_date) }.each do |de|
        patient2.dataElements.push de
      end
      [patient1, patient2]
    end

    def self.de_before_split_date(de, split_date)
      # R2P TODO: how to split patient characteristic data elements?
      data_element_time(de) < split_date
    end

    def self.split_by_type(patient, effective_date, measure_period_start, random)
      # Collect unique data element categories from the patient with populated entries
      de_categories = patient.dataElements.collect(&:category).uniq.shuffle(random: random)
      de_categories.delete('patient_characteristic')

      # If there's only 1 data element category, split by date instead
      return split_by_date(patient, effective_date, measure_period_start, random) if de_categories.count < 2

      patient1 = patient.clone
      patient2 = patient.clone

      # Find a split point so each cloned patient gets at least one data element category (hence, at least one entry)
      split_point = random.rand(1..(de_categories.size - 1))

      patient1 = set_patient_de_for_category(patient1, patient, de_categories, 0, split_point)
      patient2 = set_patient_de_for_category(patient2, patient, de_categories, split_point, de_categories.size)

      [patient1, patient2]
    end

    def self.set_patient_de_for_category(new_patient, old_patient, categories, start_point, end_point)
      new_patient.dataElements = []
      categories[start_point...end_point].each do |cat|
        old_cat_des = old_patient.get_data_elements(cat)
        old_cat_des.each { |de| new_patient.dataElements.push de }
      end
      # always add patient characteristics
      old_cat_des = old_patient.get_data_elements('patient_characteristic')
      old_cat_des.each { |de| new_patient.dataElements.push de }
      new_patient
    end

    def self.sort_by_start_time(data_elements)
      data_elements.keep_if { |de| de.category != 'patient_characteristic' }
      # TODO: R2P: check there's an attribute reader for highClosed (and lowClosed)
      # sort by start date (in convert start_date equivalent to authorDatetime)
      data_elements.sort_by { |de| data_element_time(de) }
    end

    def self.data_element_time(data_element)
      return data_element.relevantPeriod.low if data_element['relevantPeriod']
      return data_element.prevalencePeriod.low if data_element['prevalencePeriod']
      return data_element.authorDatetime if data_element['authorDatetime']
    end

    def self.find_split_date(patient, effective_date, measure_period_start, random)
      sorted_de = sort_by_start_time(patient.dataElements)

      first_date = find_first_date_after(sorted_de, measure_period_start)
      last_date = find_last_date_before(sorted_de, effective_date)
      if first_date && last_date && (first_date != last_date)
        rand_sec = ((last_date.to_datetime - first_date.to_datetime) * 24 * 60 * 60).to_i * random.rand
        return first_date + rand_sec.seconds
      end
      nil
    end

    def self.find_first_date_after(sorted_de, date)
      des = sorted_de.detect { |de| (data_element_time(de) > date) }
      data_element_time(des)
    end

    def self.find_last_date_before(sorted_de, date)
      # pairwise enumeration across data elements
      sorted_de.each_cons(2) do |des|
        return data_element_time(des[0]) if data_element_time(des[1]) > date
      end
      data_element_time(sorted_de.last)
    end
  end
end
