module Cypress
  class ClinicalRandomizer
    def self.randomize(record, effective_date, measure_period_start, random: Random.new)
      case random.rand(2)
      when 0
        split_by_date(record, effective_date, measure_period_start, random)
      when 1
        split_by_type(record, effective_date, measure_period_start, random)
      end
    end

    def self.split_by_date(record, effective_date, measure_period_start, random)
      record1 = record.clone
      record2 = record.clone

      # Find a date that splits the entries such that at least 1 is in each record
      split_date = find_split_date(record, effective_date, measure_period_start, random)

      # Sort the entries from earliest to latest so we can split them more easily
      entries = sort_by_start_time(record.entries)

      Record::Sections.reject { |s| s == :insurance_providers }.each do |section|
        record1.send section.to_s + '=', []
        record2.send section.to_s + '=', []
      end
      if split_date
        record1, record2 = set_entries(entries, record1, record2, split_date)
      else
        entries.each { |ent| record1.send(get_entry_type(ent._type)).push ent }
      end

      [record1, record2]
    end

    def self.set_entries(entries, record1, record2, split_date)
      entries.take_while { |ent| ent_before_split_date(ent, split_date) }.each do |ent|
        record1.send(get_entry_type(ent._type)).push ent
      end
      entries.drop_while { |ent| ent_before_split_date(ent, split_date) }.each do |ent|
        record2.send(get_entry_type(ent._type)).push ent
      end
      [record1, record2]
    end

    def self.ent_before_split_date(ent, split_date)
      (ent.start_time && ent.start_time < split_date) || (ent.time && ent.time < split_date)
    end

    def self.get_entry_type(entry_type)
      if entry_type == 'LabResult'
        'results'
      else
        entry_type.tableize
      end
    end

    def self.split_by_type(record, effective_date, measure_period_start, random)
      # Collect unique entry types from the record with populated entries
      entry_types = record.entries.collect(&:_type).uniq.shuffle(random: random)
      entry_types.delete('InsuranceProvider')

      # If there's only 1 entry type, split by date instead
      return split_by_date(record, effective_date, measure_period_start, random) if entry_types.count < 2

      record1 = record.clone
      record2 = record.clone

      # Find a split point so each cloned record gets at least one entry type (hence, at least one entry)
      split_point = random.rand(1..(entry_types.size - 1))

      record1 = set_record_sections_for_type(record1, record, entry_types, 0, split_point)
      record2 = set_record_sections_for_type(record2, record, entry_types, split_point, entry_types.size)

      [record1, record2]
    end

    def self.set_record_sections_for_type(new_record, old_record, entry_types, start_point, end_point)
      Record::Sections.each do |section|
        new_record.send section.to_s + '=', [] unless section == :insurance_providers
      end

      entry_types[start_point...end_point].each do |elem|
        type = get_entry_type(elem)
        new_record.send(type).push old_record.send(type)
      end

      new_record
    end

    def self.sort_by_start_time(entries)
      entries.delete_if { |e| e._type == 'InsuranceProvider' }.sort do |x, y|
        if x.start_time.nil? && x.time.nil?
          -1
        elsif y.start_time.nil? && x.time.nil?
          1
        else
          x_time = x.start_time ? x.start_time : x.time
          y_time = y.start_time ? y.start_time : y.time
          x_time <=> y_time
        end
      end
    end

    def self.find_split_date(record, effective_date, measure_period_start, random)
      entries = sort_by_start_time(record.entries)
      first_date = find_first_date_after(entries, measure_period_start)
      last_date = find_last_date_before(entries, effective_date)
      if first_date && last_date && (first_date != last_date)
        return (last_date - first_date) * random.rand + first_date
      end
      nil
    end

    def self.find_first_date_after(entries, date)
      ents = entries.detect { |ent| (ent.start_time && ent.start_time > date) || (ent.time && ent.time > date) }
      ents.try(:start_time) ? ents.try(:start_time) : ents.try(:time)
    end

    def self.find_last_date_before(entries, date)
      entries.each_cons(2) do |ents|
        return ents[0].start_time if (ents[1].start_time && ents[1].start_time > date) || (ents[1].time && ents[1].time > date)
      end
      entries.last.try(:start_time) ? entries.last.try(:start_time) : entries.last.try(:time)
    end
  end
end
