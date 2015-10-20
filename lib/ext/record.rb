# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  field :test_id
  field :bundle_id
  field :measures, type: Hash
  index test_id: 1
  index bundle_id: 1
  def bundle
    if !self["bundle_id"].nil?
      HealthDataStandards::CQM::Bundle.find(self["bundle_id"])
    elsif !self["test_id"].nil?
      ProductTest.find(self["test_id"]).bundle
    end
  end

  def original_record
    if self["original_medical_record_number"]
      return bundle.records.where({"medical_record_number" => self["original_medical_record_number"]}).first
    end
  end
end
