# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  # field :bundle_id
  field :measures, type: Hash
  index test_id: 1
  index bundle_id: 1

  def destroy
    calculation_results.destroy
    delete
  end

  def product_test
    ProductTest.where('_id' => test_id).most_recent
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
    date.year - dob.year - (date.month > dob.month || (date.month == dob.month && date.day >= dob.day) ? 0 : 1)
  end

  def original_record
    if self['original_medical_record_number']
      bundle.records.where('medical_record_number' => self['original_medical_record_number']).first
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
    changed = { medical_record_number: medical_record_number, first: [first, first], last: [last, last] }
    rec, changed = randomize_record_name_or_birth(rec, changed, random: random)
    randomize_demographics(rec, changed, random: random)
  end

  private

  def randomize_record_name_or_birth(rec, changed, random: Random.new)
    case random.rand(3) # random chooses which part of the record is modified
    when 0 # first name
      rec = randomize_record_name_first(rec, random: random)
      changed[:first] = [first, rec.first]
    when 1 # last name
      rec = randomize_record_name_last(rec, random: random)
      changed[:last] = [last, rec.last]
    when 2 # birthdate
      rec.birthdate = DateTime.strptime(rec.birthdate.to_s, '%s').change(
        case random.rand(3)
        when 0 then { day: 1, month: 1 }
        when 1 then { day: random.rand(28) + 1 }
        when 2 then { month: random.rand(12) + 1 }
        end
      ).strftime('%s').to_i
      changed[:birthdate] = [birthdate, rec.birthdate]
    end
    [rec, changed]
  end

  def randomize_record_name_first(rec, random: Random.new)
    case random.rand(3) # random chooses how to modify the field
    when 0 then rec.first = rec.first[0] # replace with initial
    when 1 then rec.first = replace_random_char(rec.first.clone, random: random) # insert incorrect letter
    when 2 # nickname
      nicknames = NAMES_RANDOM['nicknames'][rec.gender][rec.first]
      rec.first = nicknames.blank? ? rec.first[0] : nicknames.sample(random: random)
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

  def randomize_demographics(rec, changed, random: Random.new)
    case random.rand(3) # now, randomize demographics
    when 0 # gender
      rec.gender = %w[M F].sample(random: random)
      changed[:gender] = [gender, rec.gender]
    when 1 # race
      rec.race = APP_CONSTANTS['randomization']['races'].sample(random: random)
      changed[:race] = [race.code, rec.race.code]
    when 2 # ethnicity
      rec.ethnicity = APP_CONSTANTS['randomization']['ethnicities'].sample(random: random)
      changed[:ethnicity] = [ethnicity.code, rec.ethnicity.code]
    end
    [rec, changed, self]
  end
end
