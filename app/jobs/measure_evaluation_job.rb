class MeasureEvaluationJob < ActiveJob::Base
  queue_as :default
  include Job::Status
  def perform(test_or_task, options)
    if test_or_task.is_a? ProductTest
      perform_for_product_test(test_or_task, options)
    elsif test_or_task.is_a? Task
      perform_for_task(test_or_task, options)

    end
  end

  def perform_for_task(task, options)
    results = eval_measures(task.product_test.measures, task.product_test, options)
    task.expected_results = results
    task.save
  end

  def perform_for_product_test(product_test, options)
    results = eval_measures(product_test.measures, product_test, options)

    product_test.expected_results = results
    product_test.save
  end

  def eval_measures(measures, product_test, options, &_block)
    results = {}
    measures.each_with_index do |measure|
      dictionary = generate_oid_dictionary(measure, measure.bundle_id)
      qr = QME::QualityReport.find_or_create(measure['hqmf_id'], measure.sub_id, 'bundle_id' => product_test.bundle.id,
                                                                                 'effective_date' => product_test.effective_date,
                                                                                 'test_id' => product_test.id,
                                                                                 :filters => options['filters'],
                                                                                 'enable_logging' => Cypress::AppConfig['enable_logging'],
                                                                                 'enable_rationale' => true)

      qr.calculate({ 'bundle_id' => product_test.bundle.id,
                     'oid_dictionary' => dictionary,
                     'prefilter' => { test_id: product_test.id } }, false)
      qr.reload
      result = qr.result
      res = result.as_document
      res.delete('_id')
      res['measure_id'] = measure.hqmf_id
      results[measure.key] = res
    end
    results
  end

  def generate_oid_dictionary(measure, bundle_id)
    valuesets = HealthDataStandards::CQM::Bundle.find(bundle_id).value_sets.in(oid: measure.oids)
    js = {}
    valuesets.each do |vs|
      js[vs.oid] = cached_value(vs)
    end
    js.to_json
  end

  def cached_value(vs)
    @loaded_valuesets ||= {}
    return @loaded_valuesets[vs.oid] if @loaded_valuesets[vs.oid]
    js = {}
    vs.concepts.each do |con|
      name = con.code_system_name
      js[name] ||= []
      js[name] << con.code.downcase unless js[name].index(con.code.downcase)
    end
    @loaded_valuesets[vs.oid] = js
    js
  end
end
