# frozen_string_literal: true

module FilteringTestsHelper
  include ChecklistTestsHelper

  def display_filter_val(filter_name, vals)
    return [] if vals == [] # ie, the filter values haven't been chosen yet
    return providers_val(vals) if filter_name == 'providers'
    return problems_val(vals) if filter_name == 'problems'
    return age_val(vals) if filter_name == 'age'

    arr = []
    vals.each do |val|
      case filter_name
      when 'races', 'ethnicities'
        key_name = APP_CONSTANTS['randomization'][filter_name].find { |x| x.code == val }.name
        arr << "#{key_name} (code: #{val})"
      when 'genders', 'payers'
        arr << val
      end
    end
    arr
  end

  def display_filter_title(filter_name, task)
    if filter_name == 'age'
      eff_date = display_time(task.product_test.created_at)
      return "Age As Of #{eff_date}"
    end

    filter_name.titleize
  end

  def age_val(val)
    arr = []
    arr << { Minimum: val['min'] } if val['min']
    arr << { Maximum: val['max'] } if val['max']
    arr
  end

  def problems_val(val)
    oid = val[:oid].first
    code_values = direct_reference_code?(oid) ? lookup_codevalues(oid).first : lookup_valueset_long_name(oid)
    ["SNOMEDCT codes in #{code_values.first} (code: #{code_values.second})"]
  end

  def providers_val(val)
    arr = []
    arr << { NPIs: val.npis.join(',') }
    arr << { TINs: val.tins.join(',') }

    arr << { Addresses: val.addresses.map.map(&:values).map { |a| a.join(', ') }.join(' and ') } if val.key?('addresses') || val.key?(:addresses)

    arr
  end
end
