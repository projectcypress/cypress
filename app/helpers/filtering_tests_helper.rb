module FilteringTestsHelper
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
    ["SNOMEDCT codes in #{ValueSet.where(oid: val[:oid].first).first.display_name} (code: #{val[:oid].first})"]
  end

  def providers_val(val)
    arr = []
    arr << { NPIs: val.npis.join(',') }
    arr << { TINs: val.tins.join(',') }

    arr << { Addresses: val.addresses.map.map(&:values).map { |a| a.join(', ') }.join(' and ') } if val.key?('addresses') || val.key?(:addresses)

    arr
  end

  def generate_filter_patients(filter_tests)
    return unless filter_tests

    test = filter_tests.pop
    test.generate_patients
    test.save
    test.queued
    ProductTestSetupJob.perform_later(test)
    patients = test.patients
    filter_tests.each do |ft|
      patients.collect do |p|
        p2 = p.clone
        p2.extendedData['correlation_id'] = ft.id
        p2.save
        p2
      end
      ft.save
      ft.queued
      ProductTestSetupJob.perform_later(ft)
    end
  end
end
