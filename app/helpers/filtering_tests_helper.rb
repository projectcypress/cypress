module FilteringTestsHelper
  def display_filter_val(filter_name, vals)
    return providers_val(vals) if filter_name == 'providers'
    return problems_val(vals) if filter_name == 'problems'
    return age_val(vals) if filter_name == 'age'

    arr = []
    vals.each do |val|
      case filter_name
      when 'races', 'ethnicities'
        arr << "#{APP_CONFIG.randomization[key].find { |x| x.code == val }.name} (code: #{val})"
      when 'genders', 'payers'
        arr << val
      end
    end
    arr
  end

  def age_val(val)
    arr = []
    arr << { Minimum: val['min'] } if val['min']
    arr << { Maximum: val['max'] } if val['max']
    arr
  end

  def problems_val(val)
    "#{HealthDataStandards::SVS::ValueSet.where(oid: val[:oid].first).first.display_name} (code: #{val[:oid].first})"
  end

  def providers_val(val)
    arr = []
    arr << { NPIs: val.npis.join(',') }
    arr << { TINs: val.tins.join(',') }

    if val.key?('addresses') || val.key?(:addresses)
      arr << { Addresses: val.addresses.map.map(&:values).map { |a| a.join(', ') }.join(' and ') }
    end

    arr
  end
end
