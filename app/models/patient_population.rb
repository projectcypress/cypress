# TestPopulations are subsets of the Master Patient List. Each Test that is executed for a Product uses a TestPopulation
# to keep track of the Records who will be considered in measure calculation.

class PatientPopulation
  include Mongoid::Document
  include HealthDataStandards::CQM

  belongs_to :product_test, index: true
  belongs_to :user, index: true
  has_and_belongs_to_many :records, index: true

  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :patient_ids, type: Array

  validates_presence_of :id
  validates_presence_of :name
  validates_presence_of :patient_ids

  def self.installed
    PatientPopulation.order_by([["name", :asc]]).to_a
  end

  def self.min_coverage(measures, bundle)
    bundle_id = (bundle.kind_of? Bundle)? bundle.id : bundle
    bundle = (bundle.kind_of? Bundle)? bundle : Bundle.find(bundle)
    effective_date = bundle.effective_date

    numerator_patient_counts = PatientCache.patient_counts_for_measures(bundle_id, measures,
                                                                        effective_date, :numerator)

    measures_to_numerator = PatientCache.measures_to_patients_for_population(bundle_id, measures, effective_date, :numerator)
    measures_to_denominator = PatientCache.measures_to_patients_for_population(bundle_id, measures, effective_date, :denominator)
    measures_to_exclusion = PatientCache.measures_to_patients_for_population(bundle_id, measures, effective_date, :exclusions)

    minimum_set = []

    # Full set starts with all numerator patients
    full_set = numerator_patient_counts.map {|npc| npc["_id"]}

    # Add the most valuable patient for the numerator to the list
    measures_to_numerator.each do |m_to_n|
      mvp = numerator_patient_counts.find {|npc| m_to_n["patients"].include?(npc['_id'])}
      minimum_set << mvp["_id"]
    end

    measures_to_denominator.each do |m_to_d|
      # Are there any pure denominator patients to choose from?
      if (m_to_d["patients"] & minimum_set).empty?
        minimum_set << m_to_d["patients"].sample
      end

      full_set.concat(m_to_d["patients"])
    end

    measures_to_exclusion.each do |e_to_d|
      # Are there any pure exclusion patients to choose from?
      if (e_to_d["patients"] & minimum_set).empty?
        minimum_set << e_to_d["patients"].sample
      end

      full_set.concat(e_to_d["patients"])
    end

    minimum_set.uniq!
    full_set.uniq!

    {:minimal_set => minimum_set, :overflow => full_set - minimum_set}
  end
end
