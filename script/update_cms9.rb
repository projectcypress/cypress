require 'mongoid'

Mongoid.load!('config/mongoid.yml', :production)
db = Mongoid::Clients.default

newpops = { 'IPP' => '9178ED61-94FF-47A2-B27E-B20E711B13D3',
            'DENOM' => 'BA697B73-CE2E-4900-848E-DCB5C96159BA',
            'DENEX' => '09569216-9600-407B-85BF-8930736E3BF6',
            'NUMER' => '58C5415A-19C5-454F-8419-33F02737A1E4'
          }

db[:patient_cache].find(:'value.measure_id' => '40280382-5971-4EED-015A-4D802E4E4A61').each do |pc|
  db[:patient_cache].update_one({ '_id' => pc['_id'] }, '$set' => { :'value.measure_id' => '40280382-5ABD-FA46-015B-164FA3A824E4' })
end

db[:query_cache].find(measure_id: '40280382-5971-4EED-015A-4D802E4E4A61').each do |qc|
  results = qc['result']
  results['population_ids'] = newpops
  db[:query_cache].update_one({ '_id' => qc['_id'] }, '$set' => { measure_id: '40280382-5ABD-FA46-015B-164FA3A824E4',
                                                                  result:  results,
                                                                  population_ids: newpops })
end

db[:bundles].find(version: '2017.0.1').each do |bund|
  measure_ids = bund['measures']
  measure_ids.delete('40280382-5971-4EED-015A-4D802E4E4A61')
  measure_ids << '40280382-5ABD-FA46-015B-164FA3A824E4'
  db[:bundles].update_one({ '_id' => bund['_id'] }, '$set' => { measures: measure_ids,
                                                                version: '2017.0.1.1' })
end

db[:measures].find(hqmf_id: '40280382-5971-4EED-015A-4D802E4E4A61').each do |mes|
  hqmf_doc = mes['hqmf_document']
  hqmf_doc['hqmf_id'] = '40280382-5ABD-FA46-015B-164FA3A824E4'
  hqmf_doc['population_criteria']['IPP']['hqmf_id'] = '9178ED61-94FF-47A2-B27E-B20E711B13D3'
  hqmf_doc['population_criteria']['DENOM']['hqmf_id'] = 'BA697B73-CE2E-4900-848E-DCB5C96159BA'
  hqmf_doc['population_criteria']['NUMER']['hqmf_id'] = '58C5415A-19C5-454F-8419-33F02737A1E4'
  hqmf_doc['population_criteria']['DENEX']['hqmf_id'] = '09569216-9600-407B-85BF-8930736E3BF6'
  db[:measures].update_one({ '_id' => mes['_id'] }, '$set' => { hqmf_id: '40280382-5ABD-FA46-015B-164FA3A824E4',
                                                                id: '40280382-5ABD-FA46-015B-164FA3A824E4',
                                                                hqmf_document: hqmf_doc,
                                                                population_ids: newpops })
end

db[:products].find(measure_ids: '40280382-5971-4EED-015A-4D802E4E4A61').each do |prod|
  measure_ids = prod['measure_ids']
  measure_ids.delete('40280382-5971-4EED-015A-4D802E4E4A61')
  measure_ids << '40280382-5ABD-FA46-015B-164FA3A824E4'
  db[:products].update_one({ '_id' => prod['_id'] }, '$set' => { measure_ids: measure_ids })
end

db[:product_tests].find(measure_ids: '40280382-5971-4EED-015A-4D802E4E4A61').each do |prod|
  measure_ids = prod['measure_ids']
  measure_ids.delete('40280382-5971-4EED-015A-4D802E4E4A61')
  measure_ids << '40280382-5ABD-FA46-015B-164FA3A824E4'
  if prod['_type'] == 'ChecklistTest'
    db[:product_tests].update_one({ '_id' => prod['_id'] }, '$set' => { measure_ids: measure_ids })
  else
    expected = prod['expected_results']
    expected['40280382-5ABD-FA46-015B-164FA3A824E4'] = expected['40280382-5971-4EED-015A-4D802E4E4A61']
    expected['40280382-5ABD-FA46-015B-164FA3A824E4']['measure_id'] = '40280382-5ABD-FA46-015B-164FA3A824E4'
    expected['40280382-5ABD-FA46-015B-164FA3A824E4']['population_ids'] = newpops
    expected.delete('40280382-5971-4EED-015A-4D802E4E4A61')
    db[:product_tests].update_one({ '_id' => prod['_id'] }, '$set' => { measure_ids: measure_ids,
                                                                        expected_results: expected })
  end
end

c1_config = YAML.load(File.read('config/cat1checklist.yml'))
c1_config['40280382-5ABD-FA46-015B-164FA3A824E4'] = c1_config['40280382-5971-4EED-015A-4D802E4E4A61']
File.open('config/cat1checklist.yml', 'w') { |f| YAML.dump(c1_config, f) }
