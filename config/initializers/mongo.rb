module QME
  # create a unique index for patient cache, this prevents a race condition where the same patient can be entered multiple times for a patient
  #TODO create indexes for cahces
   MONGO_DB['patient_cache'].indexes.create({"value.measure_id"=> 1, "value.sub_id"=> 1, "value.effective_date"=> 1, "value.patient_id"=> 1}, {'unique'=> true})

  base_fields = [['value.measure_id', 1], ['value.sub_id', 1], ['value.effective_date', 1], ['value.test_id', 1], ['value.manual_exclusion', 1]]

   %w(population denominator numerator antinumerator exclusions).each do |group|
     MONGO_DB['patient_cache'].indexes.create(Hash[*base_fields.clone.concat([["value.#{group}", 1]]).flatten(1)], {name: "#{group}_index"})
   end

  # Make sure we're indexing records by test_id so we can find them quickly during measure calculation
   MONGO_DB['records'].indexes.create({'value.test_id'=> 1})

  module DatabaseAccess
    # Monkey patch in the connection for the application
    def get_db
      MONGO_DB
    end
  end
end
