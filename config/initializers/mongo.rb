module QME
  Mongoid.logger.level = Logger::INFO
  Mongo::Logger.logger.level = Logger::WARN
  patient_cache = Mongoid.default_client['patient_cache']
  # create a unique index for patient cache, this prevents a race condition where the same patient can be entered multiple times for a patient
  patient_cache.indexes.create_one({ 'value.measure_id' => 1, 'value.sub_id' => 1, 'value.effective_date' => 1, 'value.patient_id' => 1 },
                                   'unique' => true)

  patient_cache.indexes.create_one('value.last' => 1)

  base_fields = [['value.measure_id', 1], ['value.sub_id', 1], ['value.effective_date', 1], ['value.test_id', 1], ['value.manual_exclusion', 1]]

  %w(population denominator numerator antinumerator exclusions).each do |group|
    patient_cache.indexes.create_one(Hash[*base_fields.clone.concat([["value.#{group}", 1]]).flatten(1)], name: "#{group}_index")
  end

  # Make sure we're indexing records by test_id so we can find them quickly during measure calculation
  Mongoid.default_client['records'].indexes.create_one('value.test_id' => 1)
end
