module HealthDataStandards
  module CQM
    class PatientCache
      # Returns all of the patients in a population with
      # a count of how many times they appear in the measures
      # sorted in decending order of popularity
      def self.patient_counts_for_measures(bundle_id, measures, effective_date, population)
        matching_criteria = build_matching_criteria(bundle_id, measures, effective_date, population)

        self.collection.aggregate([
          {"$match" => matching_criteria},
          {"$group" => {"_id" => "$value.medical_record_id",
                        "count" => {"$sum" => 1}}},
          {"$sort" => {"count" => -1}}
        ])
      end

      def self.measures_to_patients_for_population(bundle_id, measures, effective_date, population)
        matching_criteria = build_matching_criteria(bundle_id, measures, effective_date, population)
        self.collection.aggregate([
          {"$match" => matching_criteria},
          {"$group" => {"_id" => {"measure_id" => "$value.measure_id", "sub_id" => "$value.sub_id"},
                        "patients" => {"$addToSet" => "$value.medical_record_id"}}}
        ])
      end

      private
      def self.build_matching_criteria(bundle_id, measures, effective_date, population)
        matching_criteria = {"value.measure_id" => {"$in" => measures},
                             "value.effective_date" => effective_date,
                             "value.test_id" => nil,
                             "bundle_id" => bundle_id}
        matching_criteria.merge case population
        when :numerator
          {"$or" => [{"value.NUMER" => {"$gt" => 0}}, {"value.MSRPOPL" => {"$gt" => 0}}]}
        when :denominator
          {"value.NUMER"=> 0, "value.DENOM" => {"$gt" => 0}}
        when :exclusions
          {"value.NUMER"=> 0, "value.DENEX" => {"$gt" => 0}}
        end
      end
    end
  end
end