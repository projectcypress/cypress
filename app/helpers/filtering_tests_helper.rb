module FilteringTestsHelper
  def display_filter_val(key, vals)
    return providers_val(vals) if key == 'providers'
    return [vals['min'] ? "min: #{vals['min']}" : '', vals['max'] ? "max: #{vals['max']}" : ''].reject(&:empty?).join(', ') if key == 'age'
    arr = []
    vals.each do |val|
      case key
      when 'races', 'ethnicities'
        arr << "#{APP_CONFIG.randomization[key].find { |x| x.code == val }.name} (code: #{val})"
      when 'genders', 'payers'
        arr << val
      when 'problems'
        arr << "#{HealthDataStandards::SVS::ValueSet.where(oid: val).first.display_name} (code: #{val})"
      end
    end
    arr.join(', ')
  end

  def providers_val(val)
    arr = []
    arr << "NPIS: #{val.npis.join(', ')}"
    arr << "TINS: #{val.tins.join(', ')}"
    val.addresses.each do |address|
      arr << address.map { |_k, v| v }.join(', ')
    end
    arr.join(' | ')
  end
end
