# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  field :test_id, type: BSON::ObjectId
  field :bundle_id
  field :measures, type: Hash
  index test_id: 1
  index bundle_id: 1

  def calcuation_results
    HealthDataStandards::CQM::PatientCache.where('value.patient_id' => id)
                                          .order_by(['value.last', :asc])
  end

  def destroy
    calcuation_results.destroy
    delete
  end

  def product_test
    ProductTest.where('_id' => test_id).first
  end

  def bundle
    if !self['bundle_id'].nil?
      HealthDataStandards::CQM::Bundle.find(self['bundle_id'])
    elsif !self['test_id'].nil?
      ProductTest.find(self['test_id']).bundle
    end
  end

  def age_at(date)
    dob = Time.at(birthdate).utc
    date.year - dob.year - ((date.month > dob.month || (date.month == dob.month && date.day >= dob.day)) ? 0 : 1)
  end

  def original_record
    if self['original_medical_record_number']
      return bundle.records.where('medical_record_number' => self['original_medical_record_number']).first
    end
  end

  def calculation_results
    HealthDataStandards::CQM::PatientCache.where('value.patient_id' => id).where('value.IPP'.to_sym.gt => 0)
  end

  def lookup_provider(include_address = nil)
    provider = Provider.find(provider_performances.first['provider_id'])
    addresses = []
    provider.addresses.each do |address|
      addresses << { 'street' => address.street, 'city' => address.city, 'state' => address.state, 'zip' => address.zip,
                     'country' => address.country }
    end

    return { 'npis' => [provider.npi], 'tins' => [provider.tin], 'addresses' => addresses } if include_address
    { 'npis' => [provider.npi], 'tins' => [provider.tin] }
  end
end
