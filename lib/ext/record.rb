# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  field :measures, type: Hash
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
