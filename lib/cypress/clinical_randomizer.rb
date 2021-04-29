# frozen_string_literal: true

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
      patient_char_de = patient.qdmPatient.get_data_elements('patient_characteristic')
      patient1 = patient.clone
      patient2 = patient.clone

      non_pc_de = patient.qdmPatient.dataElements.reject { |de| de.qdmCategory == 'patient_characteristic' }
      sorted_de_groups = sort_groups_by_start_time(find_related_to_de(non_pc_de))

      # Find a date that splits the data_elements such that at least 1 is in each patient
      split_date = find_split_date(sorted_de_groups, effective_date, measure_period_start, random)

      if split_date
        patient1, patient2 = set_split_data_elements(sorted_de_groups, patient1, patient2, split_date)
      else
        # set all patient1 data elements
        patient1.qdmPatient.dataElements = non_pc_de
        patient2.qdmPatient.dataElements = []
      end
      patients_with_characteristics(patient1, patient2, patient_char_de)
    end

    def self.patients_with_characteristics(patient1, patient2, patient_char_de)
      patient1.qdmPatient.dataElements.concat patient_char_de
      patient2.qdmPatient.dataElements.concat patient_char_de
      [patient1, patient2]
    end

    # note: also adds any related to elements, which may not be in the same date split
    def self.set_split_data_elements(sorted_de_groups, patient1, patient2, split_date)
      patient1.qdmPatient.dataElements = []
      patient2.qdmPatient.dataElements = []
      sorted_de_groups.take_while { |group| de_before_date(group.first, split_date) }.each do |group|
        patient1.qdmPatient.dataElements.concat group
      end
      sorted_de_groups.drop_while { |group| de_before_date(group.first, split_date) }.each do |group|
        patient2.qdmPatient.dataElements.concat group
      end
      [patient1, patient2]
    end

    def self.de_before_date(data_element, date)
      data_element_time(data_element) < date
    end

    def self.split_by_type(patient, effective_date, measure_period_start, random)
      patient_char_de = patient.qdmPatient.get_data_elements('patient_characteristic')
      non_pc_de = patient.qdmPatient.dataElements.reject { |de| de.qdmCategory == 'patient_characteristic' }
      de_groups = find_related_to_de(non_pc_de)

      # Collect unique data element categories from each related group
      de_categories = de_groups.map(&:first).collect(&:qdmCategory).uniq.shuffle(random: random)

      # If there's only 1 data element category, split by date instead
      return split_by_date(patient, effective_date, measure_period_start, random) if de_categories.count < 2

      patient1 = patient.clone
      patient2 = patient.clone

      # Find a split point so each cloned patient gets at least one data element category (hence, at least one entry)
      split_point = random.rand(1..(de_categories.size - 1))

      patient1.qdmPatient.dataElements = de_for_category(de_groups, de_categories, 0, split_point)
      patient2.qdmPatient.dataElements = de_for_category(de_groups, de_categories, split_point, de_categories.size)

      patients_with_characteristics(patient1, patient2, patient_char_de)
    end

    # note: also adds any related to elements, which may not be the same category
    def self.de_for_category(de_groups, categories, start_point, end_point)
      data_elements = []
      categories[start_point...end_point].each do |cat|
        category_groups = de_groups.select { |group| group.first.qdmCategory == cat }
        data_elements.concat(category_groups.flatten)
      end
      data_elements
    end

    # sorts by first data element in group
    def self.sort_groups_by_start_time(de_groups)
      # sort by start date (in convert start_date equivalent to authorDatetime)
      de_groups.sort_by { |de_group| data_element_time(de_group.first) }
    end

    def self.data_element_time(data_element)
      return data_element.relevantPeriod.low if data_element['relevantPeriod']&.low
      return data_element.relevantDatetime if data_element['relevantDatetime']
      return data_element.prevalencePeriod.low if data_element['prevalencePeriod']&.low
      return data_element.authorDatetime if data_element['authorDatetime']
      return data_element.resultDatetime if data_element['resultDatetime']
      return data_element.sentDatetime if data_element['sentDatetime']
      return data_element.participationPeriod.low if data_element['participationPeriod']
    end

    def self.find_split_date(sorted_de_groups, effective_date, measure_period_start, random)
      # sorted_de = sort_by_start_time(patient.qdmPatient.dataElements)
      sorted_de = sorted_de_groups.map(&:first)
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

    # find de with relate_to reference and group accordingly
    # essentially identifies sets of data elements that are "connected"
    # each list in the result is a different connected set
    def self.find_related_to_de(data_elements)
      grouped_de = []
      added = data_elements.map { |_de| false }
      data_elements.each_with_index do |de, index|
        next if added[index]

        grouped_de.push([de])
        added[index] = true
        # iterate through relatedTo and find each match in the data element list
        de&.relatedTo&.each { |related| group_reference(related, grouped_de, data_elements, added) } if de.respond_to?(:relatedTo)
      end
      grouped_de
    end

    def self.group_reference(related, grouped_de, data_elements, added)
      match_idx = data_elements.index { |x| x.id == related }

      # if can't find reference
      return unless match_idx

      # check if match has been added already
      if added[match_idx]
        # find match in grouped_de sublists (all but this *latest* one)
        group_idx = grouped_de.index { |group| group.include?(data_elements[match_idx]) }
        if group_idx && group_idx < grouped_de.count - 1
          # note: if in this (latest in grouped_de) sublist, there is a cycle
          # pop entire sublist and add to sublist for latest in grouped_de
          group = grouped_de.delete_at(group_idx)
          grouped_de.last.concat(group)
        end

      else
        # add match to sublist for latest in grouped_de
        grouped_de.last.push(data_elements[match_idx])
        # update added
        added[match_idx] = true
        # check match for relatedTo's and repeat for children
        if data_elements[match_idx].respond_to?(:relatedTo)
          data_elements[match_idx]&.relatedTo&.each { |ref| group_reference(ref, grouped_de, data_elements, added) }
        end
      end
    end
  end
end
