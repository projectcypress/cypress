# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  # field :bundle_id
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
    dob = Time.at(birthdate).in_time_zone
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

  def duplicate_randomization(random: Random.new)
    rec = clone
    rec = randomize_record_name_or_birth(rec, random: random)
    randomize_demographics(rec, random: random)
  end

  private

  def randomize_record_name_or_birth(rec, random: Random.new)
    case random.rand(3) # random chooses which part of the record is modified
    when 0 # first name
      rec = randomize_record_name_first(rec, random: random)
    when 1 # last name
      rec = randomize_record_name_last(rec, random: random)
    when 2 # birthdate
      rec.birthdate = DateTime.strptime(rec.birthdate.to_s, '%s').change(
        case random.rand(3)
        when 0 then { day: 1, month: 1 }
        when 1 then { day: random.rand(28) + 1 }
        when 2 then { month: random.rand(12) + 1 }
        end).strftime('%s').to_i
    end
    rec
  end

  def randomize_record_name_first(rec, random: Random.new)
    case random.rand(3) # random chooses how to modify the field
    when 0 then rec.first = rec.first[0] # replace with initial
    when 1 then rec.first = replace_random_char(rec.first.clone, random: random) # insert incorrect letter
    when 2 # nickname
      nicknames = NAMES_RANDOM['nicknames'][rec.gender][rec.first]
      rec.first = (nicknames.nil? || nicknames.empty?) ? rec.first[0] : nicknames.sample(random: random)
    end
    rec
  end

  def randomize_record_name_last(rec, random: Random.new)
    case random.rand(2)
    when 0 then rec.last = rec.last[0] # replace with initial
    when 1 then rec.last = replace_random_char(rec.last.clone, random: random) # insert incorrect letter
    end
    rec
  end

  def replace_random_char(rec_name, random: Random.new)
    lowercases = ('a'..'z').to_a
    lsamples = lowercases.sample(2, random: random)
    rec_name_pos = random.rand(rec_name.length - 1) + 1
    rec_name[rec_name_pos] = rec_name[rec_name_pos] != lsamples[0] ? lsamples[0] : lsamples[1]
    rec_name
  end

  def randomize_demographics(rec, random: Random.new)
    case random.rand(3) # now, randomize demographics
    when 0 # gender
      rec.gender = rec.gender == 'M' ? 'F' : 'M'
    when 1 # race
      rsamples = APP_CONSTANTS['randomization']['races'].sample(2, random: random)
      rec.race = rec.race != rsamples[0] ? rsamples[0] : rsamples[1]
    when 2 # ethnicity
      esamples = APP_CONSTANTS['randomization']['ethnicities'].sample(2, random: random)
      rec.ethnicity = rec.ethnicity != esamples[0] ? esamples[0] : esamples[1]
    end
    rec
  end
end
