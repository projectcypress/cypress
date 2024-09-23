# frozen_string_literal: true

# rubocop:disable all
namespace :dev_tasks do
  task setup: :environment

  # bundle exec rake dev_tasks:outdated_codes\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_with_overlapping_encounters\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_encounter_lengths\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_with_different_time\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_with_encounter_dx\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_with_only_author_times\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_with_priority\[2024.0.0\]
  # bundle exec rake dev_tasks:patients_with_events_before_birth\[2024.0.0\]
  # bundle exec rake dev_tasks:negated_vs\[2024.0.0\]
  # bundle exec rake dev_tasks:timezone_crosswalk\[2024.0.0\]
  SOURCE_ROOTS = { patients: 'synthea_sample_data_fhir_latest'}

  def what(json_input, x='')
    z = if json_input==[*json_input]
          [*0...json_input.size]
        else
          begin            
            json_input.keys
          rescue
            []
          end
        end
    z.flat_map do |k|
      r = (k.is_a? Integer) ? x : x + k.to_s
      # r = x + k.to_s
      case k
      when 'code'
        r = r + '|' + json_input['code'] + '|' + json_input['system'] if json_input['code'].is_a? String
      # when 'system'
      #   r = r + '|' + json_input['system'] if json_input['system'].is_a? String
      when 'url'
        r = r + '|' + json_input['url'] if json_input['url'].is_a? String
      end
      r = r.chop if (k.is_a? Integer)
      [r] + what(json_input[k], r+?.)
    end
  end

  task json_keys2: :setup do
    fhir_file = File.open("tmp/json_patient.json", 'r')
    payload = fhir_file.read
    fhir_bundle = JSON.parse(payload)
    #f=->j,x=''{z=j==[*j]?[*0...j.size]:j.keys rescue[];z.flat_map{|k|[r=x+k.to_s]+f[j[k],r+?.]}}
    #f = lambda { |json_input, x=''| z=json_input==[*json_input]?[*0...json_input.size]:json_input.keys rescue[];z.flat_map{|k|[r=x+k.to_s]+f[json_input[k],r+?.]}}
    
    scratch = { found: {} }
    profile_list = ["https://www.healthit.gov/qmcm/qpp/StructureDefinition/certqpp-qicoreencounter",
                    "https://www.healthit.gov/qmcm/qpp/StructureDefinition/certqpp-qicorepatient",
                    "https://www.healthit.gov/qmcm/qpp/StructureDefinition/certqpp-qicoresimpleobservation",]

    fhir_bundle.entry.each do |entry|
      resource = entry.resource
      
      profile_list.each do |p|
        if p == resource.meta.profile[0]
          if scratch[p] == nil
            scratch[p] = []
            scratch[:found][p] = Set.new
          end

          scratch[p] << resource
        end
      end
    end

    profile_list.each do |p|
      scratch[p].each do |scratch_resource|
        scratch[:found][p].merge(what(scratch_resource))
      end
    end
    byebug
  end

  task json_keys: :setup do
    fhir_file = File.open("tmp/json_patient.json", 'r')
    payload = fhir_file.read
    raw_json = JSON.parse(payload)
    #f=->j,x=''{z=j==[*j]?[*0...j.size]:j.keys rescue[];z.flat_map{|k|[r=x+k.to_s]+f[j[k],r+?.]}}
    f = lambda { |json_input, x=''| z=json_input==[*json_input]?[*0...json_input.size]:json_input.keys rescue[];z.flat_map{|k|[r=x+k.to_s]+f[json_input[k],r+?.]}}

    raw_json['entry'].each do |entry|
      resource = entry['resource']
      puts "****" + resource['resourceType'] + "****"
      puts f[resource]
    end
  end

  task :code_system_versions, [:bundle] => :setup do |_, args|
    cs_versions = Set.new()
    bundle = Bundle.find_by version: args.bundle
    bundle.value_sets.each do |vs|
      next if vs.oid[0,3] == 'drc'
      vs.concepts.each do |concept|
        cs_versions.add("#{concept.code_system_name}|#{concept.code_system_oid}|#{concept.code_system_version}")
      end
    end
    cs_versions.sort.each do |cs_version|
      puts cs_version
    end
  end

  task :outdated_codes, [:bundle] => :setup do |_, args|
    outdated = {}
    current_code_systems = { '2.16.840.1.113883.5.1' => '3.0.0',
                             '2.16.840.1.113883.6.238' => '1.2',
                             '2.16.840.1.113883.6.13' => '2023',
                             '2.16.840.1.113883.6.12' => '2024',
                             '2.16.840.1.113883.12.292' => '2023-11-02',
                             '2.16.840.1.113883.6.285' => '2024',
                             '2.16.840.1.113883.6.259' => '2022',
                             '2.16.840.1.113883.6.90' => '2024',
                             '2.16.840.1.113883.6.4' => '2024',
                             # '2.16.840.1.113883.6.103' => '2013',
                             # '2.16.840.1.113883.6.104' => '2013',
                             '2.16.840.1.113883.6.1' => '2.76',
                             '2.16.840.1.113883.6.301.11' => '2021',
                             '2.16.840.1.113883.6.88' => '2024-01',
                             '2.16.840.1.113883.6.96' => '2023-09',
                             '2.16.840.1.113883.3.221.5' => '9.2'
                           }
    cs_versions = Set.new()
    in_patients = {}
    bundle = Bundle.find_by version: args.bundle
    bundle.value_sets.each do |vs|
      next if vs.oid[0,3] == 'drc'
      vs.concepts.each do |concept|
        next if current_code_systems[concept.code_system_oid] == concept.code_system_version
        outdated[concept.code] = concept.code_system_oid
      end
    end
    bundle.patients.each do |patient|
      patient.qdmPatient.dataElements.each do |de|
        de.dataElementCodes.each do |dec|
          if outdated[dec.code] == dec.system
            puts "#{patient.first_names} #{patient.familyName} - #{de._type} - #{dec.code}"
            in_patients[dec.code] = dec.system
          end
        end
      end
    end
    in_patients.each do |code, system|
      bundle.value_sets.each do |vs|
        next if vs.oid[0,3] == 'drc'
        vs.concepts.each do |concept|
          if concept.code == code && concept.code_system_oid = system
            puts "#{code} - #{vs.oid}"
          end
        end
      end
    end
  end

  task :bulk_folder_import, [:file_path] => :setup do |_, args|
    path = 'tmp/synthea_sample_data_fhir_latest'
    patient_ids = []
    index = 0
    Dir.foreach(path) do |filename|
      next if filename == '.' || filename == '..' || filename == '.DS_Store'
      puts "#{index} working on #{filename}"
      index += 1
      next unless index > 115

      fhir_file = File.open("#{path}/#{filename}", 'r')
      payload = fhir_file.read
      raw_json = JSON.parse(payload)
      raw_json['entry'].each do |entry|
        resource = entry['resource']
        updatedDate = find_latest_date(resource)
        if !updatedDate.nil?
          if resource['meta']
            resource['meta']['lastUpdated'] = updatedDate
          else
            resource['meta'] = { lastUpdated: updatedDate }
          end
        end
      end
      begin
        response = RestClient::Request.execute(method: :post, url: "http://127.0.0.1:3000/", payload: raw_json.to_json, timeout: 600, headers: { accept: :json, content_type: :json })
      rescue => e
        puts '****Too Big***'
        next
      end
      next unless response.code == 200

      body = JSON.parse(response.body)
      patient_ids << body['entry'][0]['response']['location']
    end
  end

  def find_latest_date(resource)
    dates = []
    if resource['birthDate']
      dates << Time.now.iso8601
    end
    if resource['period']
      dates << resource['period']['start']
      dates << resource['period']['end']
    end
    if resource['performedPeriod']
      dates << resource['performedPeriod']['start']
      dates << resource['performedPeriod']['end']
    end
    if resource['billablePeriod']
      dates << resource['billablePeriod']['start']
      dates << resource['billablePeriod']['end']
    end
    if resource['servicedPeriod']
      dates << resource['servicedPeriod']['start']
      dates << resource['servicedPeriod']['end']
    end
    dates << resource['authoredOn']
    dates << resource['started']
    dates << resource['onsetDateTime']
    dates << resource['abatementDateTime']
    dates << resource['recordedDateTime']
    dates << resource['recordedDate']
    dates << resource['effectiveDateTime']
    dates << resource['issued']
    dates << resource['occurrenceDateTime']
    dates << resource['date']
    dates << resource['created']
    dates << resource['deceasedDateTime']
    dates << resource['manufactureDate']
    dates << resource['expirationDate']
    byebug if dates.compact.sort().last.nil? && resource['resourceType'] != 'Provenance' && resource['resourceType'] != 'Medication' && resource['resourceType'] != 'Organization' && resource['resourceType'] != 'Location' && resource['resourceType'] != 'Practitioner'
    dates.compact.sort().last
  end

  task :bulk_import, [:file_path] => :setup do |_, args|
    bundle_file = File.new('tmp/synthea_sample_data_fhir_latest.zip')
    patient_ids = []
    Zip::ZipFile.open(bundle_file.path) do |zip_file|
      fhir_files = zip_file.glob(File.join(SOURCE_ROOTS[:patients], '**', '*.json'))
      fhir_files.each_with_index do |fhir_file, index|
        puts "#{index}"
        payload = fhir_file.get_input_stream.read
        puts "#{fhir_file.name}"
        response = RestClient::Request.execute(method: :post, url: "http://127.0.0.1:3000/", payload: payload, timeout: 300, headers: { accept: :json, content_type: :json })
        next unless response.code == 200

        body = JSON.parse(response.body)
        patient_ids << body['entry'][0]['response']['location']
      end
    end
  end

  task random_names: :setup do
    CSV.open("tmp/random_names.csv", 'w', col_sep: '|') do |csv|
      200.times do
        first_name = NAMES_RANDOM['first']['M'].sample
        family_name = NAMES_RANDOM['last'].sample
        csv << ["M", "#{first_name} #{family_name}"]
      end
      200.times do
        first_name = NAMES_RANDOM['first']['F'].sample
        family_name = NAMES_RANDOM['last'].sample
        csv << ["F", "#{first_name} #{family_name}"]
      end
    end
  end

  task :sorted_vs, [:bundle] => :setup do |_, args|
    bundle = Bundle.all.first
    ValueSet.all.sort_by { |vs| vs.concepts.size }.each do |vs|
      puts "#{vs.oid} - #{vs.display_name} - #{vs.concepts.size}"
    end
  end  

  task :encounter_codes, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    measure_codes = {}
    encounter_codes = []
    bundle.measures.each do |mes|
      measure_codes[mes.cms_id] = []
      mes.source_data_criteria.each do |sdc|
        next unless sdc._type == 'QDM::EncounterPerformed'
        vs = bundle.value_sets.find_by(oid: sdc.codeListId)
        vs.concepts.each do |con|
          encounter_codes << "#{con.code}:#{con.code_system_name}" unless encounter_codes.include? "#{con.code}:#{con.code_system_name}"
          measure_codes[mes.cms_id] << "#{con.code}:#{con.code_system_name}" unless measure_codes[mes.cms_id].include? "#{con.code}:#{con.code_system_name}"
        end
      end
    end
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_encounter_cods.csv", 'w', col_sep: '|') do |csv|
      encounter_codes.each do |code|
        measures = measure_codes.select { |k, v| v.include?(code) }
        csv << [code, measures.size, measures.keys.join(',')]
      end
    end
  end

  task bulk_get: :setup do

    authrequest = RestClient::Request.execute(method: :post, url: "https://sandbox.bcda.cms.gov/auth/token",
                                                             user: "2462c96b-6427-4efb-aed7-118e20c2e997",
                                                             password: "8e87f0ebc50d10f1bc9734329a9900179b84ccd39e4d0920b905cc359cf6e94a6e760bbe3a0890c7",
                                                             headers: { accept: :json })
    access_token = JSON.parse(authrequest.body)['access_token']

    bulk_patient_request = RestClient.get 'https://sandbox.bcda.cms.gov/api/v2/Patient/$export', {:Authorization => "Bearer #{access_token}",
                                                                                                  :accept => 'application/fhir+json',
                                                                                                  :Prefer => 'respond-async'}

    content_location =  bulk_patient_request.headers[:content_location]

    sleep(10)

    bulk_job_request = RestClient.get content_location, {:Authorization => "Bearer #{access_token}"}

    JSON.parse(bulk_job_request)['output'].each do |bd|
      data = RestClient.get bd['url'], {:Authorization => "Bearer #{access_token}"}
      data.body.each_line do |fhir_resource|
        RestClient::Request.execute(method: :post,
                                    url: "http://localhost:3000/4_0_1/#{bd['type']}",
                                    payload: fhir_resource,
                                    headers: { accept: 'application/json+fhir', content_type: 'application/json+fhir' }).headers[:location]
      end
    end
  end

  task rand_ids: :setup do
    ids = []
    patient_list = Patient.distinct(:_id)
    vs_list = ValueSet.distinct(:_id)
    tries = 100000
    tries.times do
      #id_string = BSON::ObjectId.from_data("#{Patient.find(patient_list.sample).qdmPatient.dataElements.sample.id}#{additional_vs = vs_list.sample}").to_s
      id_string = BSON::ObjectId.from_data("#{BSON::ObjectId.new.to_s}#{BSON::ObjectId.new.to_s}").to_s
       puts id_string
       puts id_string[6,10] + id_string[38,10] + id_string[58,6] + id_string[86,10]
      ids << id_string[6,10] + id_string[38,10] + id_string[58,6] + id_string[86,10]
    end
    new_id_list = ids.uniq
    if new_id_list.size == tries
      puts "We're unique"
    else
      puts new_id_list.size
    end
  end

  task :measures, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    bundle.measures.sort_by { |mes| mes.cms_id.split('CMS')[1].split('v')[0].to_i }.each do |measure|
      puts "#{measure.cms_id} - #{measure.title}"
    end
  end

  task :patient_with_statement, [:bundle, :measure, :statement] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    measure_id = bundle.measures.find_by(cms_id: args.measure).id
    statement = args.statement
    bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
      found = false
      patient.calculation_results.where(measure_id: measure_id).each do |individual_result|
        break if found == true
        next unless individual_result&.statement_results&.any? { |sr| (statement == sr.statement_name) && sr.final.to_boolean == true }
        puts "#{patient.familyName} #{patient.givenNames.first}"
        found = true
      end
    end
  end

  task :patient_with_clause, [:bundle, :measure, :statement, :clause] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    measure_id = bundle.measures.find_by(cms_id: args.measure).id
    statement = args.statement
    clause = args.clause
    bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
      found = false
      patient.calculation_results.where(measure_id: measure_id).each do |individual_result|
        break if found == true
        next unless individual_result&.clause_results&.any? { |cr| (statement == cr.statement_name) && (clause == cr.localId) && cr.final.to_boolean == true }
        puts "#{patient.familyName} #{patient.givenNames.first}"
        found = true
      end
    end
  end

  task :patient_without_clause, [:bundle, :measure, :statement, :clause] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    measure_id = bundle.measures.find_by(cms_id: args.measure).id
    statement = args.statement
    clause = args.clause
    bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
      found = false
      patient.calculation_results.where(measure_id: measure_id).each do |individual_result|
        break if found == true
        next unless individual_result&.clause_results&.any? { |cr| (statement == cr.statement_name) && (clause == cr.localId) && cr.final.to_boolean == false }
        puts "#{patient.familyName} #{patient.givenNames.first}"
        found = true
      end
    end
  end

  task :coverage_for_product, [:product_name] => :setup do |_, args|
    product = Product.where(name: args.product_name).first
    product.product_tests.measure_tests.each do |pt|
      measure = pt.measures.first
      patients = pt.patients
      bundle = pt.bundle
      pa = PatientAnalysisJob.new.generate_analysis(patients, measure, bundle)
      puts "#{pt.cms_id}|#{patients.size}|#{pa['coverage_per_measure'][pt.cms_id]}|#{args.product_name}"
    end
  end

  task :coverage_for_cvu_product, [:product_name] => :setup do |_, args|
    product = Product.where(name: args.product_name).first
    product.product_tests.multi_measure_tests.each do |pt|
      pt.measures.each do |measure|
        patients = pt.patients
        bundle = pt.bundle
        pa = PatientAnalysisJob.new.generate_analysis(patients, measure, bundle)
        puts "#{measure.cms_id}|#{patients.size}|#{pa['coverage_per_measure'][measure.cms_id]}|#{args.product_name}"
      end
    end
  end

  # bundle exec rake dev_tasks:patients_with_vs[2021.0.3,QDM::EncounterPerformed,2.16.840.1.113883.3.464.1003.101.12.1008]
  task :patients_with_vs, [:bundle, :data_type, :oid] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    vs = bundle.value_sets.where(oid: args.oid).first
    vs_codes = vs.concepts.collect(&:code)
    CSV.open("tmp/#{args.data_type.gsub('::','_')}_#{args.oid.gsub('.','_')}.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        found = false
        next if found
        patient.qdmPatient.dataElements.each_with_index do |de, de_index|
          next unless de._type == args.data_type 
          de_codes = de.dataElementCodes.map { |de| de['code'] }
          next if (de_codes & vs_codes).empty?

          puts index
          found = true
          csv << [patient.id.to_s, patient.familyName, patient.givenNames.first, de_index, de.description, de_codes]
        end
      end
    end
  end

  # bundle exec rake dev_tasks:patients_with_vs[2021.0.3,QDM::EncounterPerformed,2.16.840.1.113883.3.464.1003.101.12.1008]
  task :patients_with_overlapping_encounters, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_encounters.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        encounters = patient.qdmPatient.get_data_elements('encounter','performed')
        encounters.each_with_index do |encounter, encounter_index|
          next unless encounters.any? { |enc| ((encounter.relevantPeriod.low.to_i == enc.relevantPeriod.low.to_i) || ((encounter.relevantPeriod.low.to_i > enc.relevantPeriod.low.to_i) && (encounter.relevantPeriod.low.to_i < enc.relevantPeriod.high.to_i))) && (encounter.id != enc.id) }
          csv << [patient.id.to_s, patient.familyName, patient.givenNames.first, encounter_index, encounter.description]
        end
      end
    end
  end

  # bundle exec rake dev_tasks:patients_with_vs[2021.0.3,QDM::EncounterPerformed,2.16.840.1.113883.3.464.1003.101.12.1008]
  task :patients_encounter_lengths, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_encounter_lenghts.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        encounters = patient.qdmPatient.get_data_elements('encounter','performed')
        encounters.each_with_index do |encounter, encounter_index|
          encounter_length = (encounter.relevantPeriod.high.to_i - encounter.relevantPeriod.low.to_i) / (60 * 60 * 24)
          next if encounter_length < 1
          csv << [patient.id.to_s, patient.familyName, patient.givenNames.first, encounter_index, encounter_length]
        end
      end
    end
  end

  # bundle exec rake dev_tasks:patients_with_vs[2021.0.3,QDM::EncounterPerformed,2.16.840.1.113883.3.464.1003.101.12.1008]
  task :patients_with_different_time, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_differing_times.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        patient.qdmPatient.dataElements.each_with_index do |de, de_index|
          times = differing_times(de)
          csv << [patient.id.to_s, "#{patient.givenNames.first} #{patient.familyName}", de._type, de_index, times] if times

          times = invalid_author_times(de)
          de.authorDatetime = times.sort.last if times
          csv << [patient.id.to_s, "#{patient.givenNames.first} #{patient.familyName}", de._type, de_index, times] if times
        end
        #patient.save
      end
    end
  end

  # bundle exec rake dev_tasks:patients_with_vs[2021.0.3,QDM::EncounterPerformed,2.16.840.1.113883.3.464.1003.101.12.1008]
  task :patients_with_encounter_dx, [:bundle] => :setup do |_, args|
    patient_code_map = {}
    code_vs_map = {}
    vs_measure_map = {}
    measure_id_map = {}
    condition_codes = []
    bundle = Bundle.find_by version: args.bundle
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_encounter_dx.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        patient_code_map[patient.id.to_s] = { name: "#{patient.familyName}_#{patient.givenNames.first}", dx_codes: [], dx_valuesets: [], dx_measures: [], relevant_dx_measures: [], dx_to_add: [] }
        has_enc_dx = false
        patient.qdmPatient.get_data_elements('encounter', 'performed').each_with_index do |de, de_index|
          de.diagnoses&.each_with_index do |enc_dx, enc_dx_index|
            has_enc_dx = true
            puts "#{patient.familyName}_#{patient.givenNames.first}|#{enc_dx.code.code}|#{enc_dx.rank}|Encounter"
            condition_codes << enc_dx.code.code
            patient_code_map[patient.id.to_s][:dx_codes] << enc_dx.code.code
            patient_code_map[patient.id.to_s][:dx_to_add] << QDM::Diagnosis.new(dataElementCodes: [enc_dx.code], prevalencePeriod: de.relevantPeriod)
          end
        end
        # next unless has_enc_dx

        # patient.qdmPatient.get_data_elements('condition').each_with_index do |de, de_index|
        #   puts "#{patient.familyName}_#{patient.givenNames.first}|#{de.dataElementCodes[0].code}||Condition"
        # end
        # patient.save
      end
    end

    patient_code_map.delete_if { |key,value| value[:dx_codes].empty? }

    vs_oids = []
    condition_codes.uniq.each do |code|
      code_vs_map[code] = { vs_oids: [] }
      bundle.value_sets.each do |vs|
        next if vs.oid[0,3] == 'drc'
        vs.concepts.each do |concept|
          if concept.code == code
            puts "#{code} - #{vs.oid}"
            vs_oids << vs.oid
            code_vs_map[code][:vs_oids] << vs.oid
          end
        end
      end
    end

    vs_oids.each do |oid|
      vs_measure_map[oid] = { measures: [] }
    end

    patient_code_map.each do |patient_id, value|
      value[:dx_codes].each do |code|
        value[:dx_valuesets].concat(code_vs_map[code][:vs_oids])
      end
    end

    bundle.measures.each do |mes|
      measure_id_map[mes.id.to_s] = mes.cms_id
      mes.source_data_criteria.each do |sdc|
        next if sdc.qdmTitle != 'Diagnosis'
        if vs_oids.include?(sdc.codeListId)
          puts "#{mes.cms_id} - #{sdc.codeListId}" 
          vs_measure_map[sdc.codeListId][:measures] << mes.cms_id
        end
      end
    end
    

    effective_date_end = Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number)
    effective_date = Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDateEnd': effective_date_end, 'effectiveDate': effective_date }

    patient_code_map.each do |patient_id, patient_code_map_value|
      patient_code_map_value[:dx_valuesets].each do |vs|
        patient_code_map_value[:dx_measures].concat(vs_measure_map[vs][:measures])
      end
      og_patient = Patient.find(patient_id)
      cw_patient = ProductTestPatient.new(og_patient.attributes.except('_id', '_type', 'providers'))
      cw_patient.qdmPatient = og_patient.qdmPatient.clone
      cw_patient.qdmPatient.dataElements.concat(patient_code_map_value[:dx_to_add])
      cw_patient.save
      patient_code_map_value[:dx_measures].each_with_index do |measure, m_index|
        original_results = SingleMeasureCalculationJob.perform_now([og_patient.id.to_s], measure_id_map.key(measure), bundle.id.to_s, options)
        cw_results = SingleMeasureCalculationJob.perform_now([cw_patient.id.to_s], measure_id_map.key(measure), bundle.id.to_s, options)
        if dev_are_results_different?(original_results, cw_results)
          patient_code_map_value[:relevant_dx_measures] << measure
        end
      end
      cw_patient.destroy
    end

    patient_code_map.delete_if { |key,value| value[:relevant_dx_measures].empty? }
    byebug
  end

  def self.invalid_author_times(data_element)
    times = []
    atime =  data_element.authorDatetime if data_element['authorDatetime']
    return nil unless atime

    times << data_element.relevantPeriod.low if data_element['relevantPeriod']&.low
    times << data_element.relevantPeriod.high if data_element['relevantPeriod']&.high
    times <<  data_element.relevantDatetime if data_element['relevantDatetime']
    times <<  data_element.prevalencePeriod.low if data_element['prevalencePeriod']&.low
    times <<  data_element.prevalencePeriod.high if data_element['prevalencePeriod']&.high
    times <<  data_element.resultDatetime if data_element['resultDatetime']
    times <<  data_element.sentDatetime if data_element['sentDatetime']
    times <<  data_element.participationPeriod.low if data_element['participationPeriod']
    times <<  data_element.birthDatetime if data_element['birthDatetime']
    times <<  data_element.expiredDatetime if data_element['expiredDatetime']
    return times if times.any? { |tv| tv > atime }
    nil
  end

  def self.differing_times(data_element)
    times = []
    times << data_element.relevantPeriod.low if data_element['relevantPeriod']&.low
    times <<  data_element.relevantDatetime if data_element['relevantDatetime']
    times <<  data_element.prevalencePeriod.low if data_element['prevalencePeriod']&.low
    # times <<  data_element.authorDatetime if data_element['authorDatetime']
    times <<  data_element.resultDatetime if data_element['resultDatetime']
    times <<  data_element.sentDatetime if data_element['sentDatetime']
    times <<  data_element.participationPeriod.low if data_element['participationPeriod']
    times <<  data_element.birthDatetime if data_element['birthDatetime']
    times <<  data_element.expiredDatetime if data_element['expiredDatetime']
    times.each do |time|
      return times if times.any? { |tv| ((time.to_i - tv.to_i).abs / (60)) > 60 }
    end
    nil
  end

  task :patients_with_only_author_times, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_only_author_time.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        patient.qdmPatient.dataElements.each_with_index do |de, de_index|
          next if ['patient_characteristic'].include? (de.qdmCategory)
          next if ['QDM::MedicationDischarge'].include? (de._type)
          if de.respond_to?(:qdmStatus)
            next if ['order'].include? (de.qdmStatus)
          end
          next if de.respond_to?(:negationRationale) && de.negationRationale
          next if de.respond_to?(:authorDatetime) && de.authorDatetime.nil?
          other_time = other_data_element_time(de)
          next unless other_time.nil?

          first_code = de.dataElementCodes.first
          concepts = ValueSet.where('concepts.code' => first_code.code, 'concepts.code_system_oid' => first_code.system, bundle_id: bundle.id).first&.concepts
          description = concepts&.detect { |x| first_code.code == "#{x.code}" }&.display_name
          csv << [patient.id.to_s, patient.familyName, patient.givenNames.first, de_index, de._type, description, de.dataElementCodes.first.code] if other_time.nil?
        end
      end
    end
  end

  task :patients_with_priority, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    CSV.open("tmp/#{args.bundle.gsub('.','_')}_priorities.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        patient.qdmPatient.dataElements.each_with_index do |de, de_index|
          next unless ['QDM::EncounterPerformed', 'QDM::ProcedureOrder', 'QDM::ProcedureRecommended', 'QDM::ProcedurePerformed'].include? (de._type)
          ranks = []
          should_have_rank = false
          if ['QDM::EncounterPerformed'].include? (de._type)
            de.diagnoses&.each do |dx|
              should_have_rank = true
              ranks << dx.rank
            end
          elsif ['QDM::ProcedureOrder', 'QDM::ProcedureRecommended', 'QDM::ProcedurePerformed'].include? (de._type)
            should_have_rank = true
            ranks << de.rank
          end
          next unless should_have_rank

          other_time = other_data_element_time(de)
          if other_time.nil?
            puts patient.id.to_s if de._type != 'QDM::ProcedureOrder'
            other_time = de.authorDatetime
          else
            first_code = de.dataElementCodes.first
            concepts = ValueSet.where('concepts.code' => first_code.code, 'concepts.code_system_oid' => first_code.system, bundle_id: bundle.id).first&.concepts
            description = concepts&.detect { |x| first_code.code == "#{x.code}" }&.display_name
            csv << [patient.id.to_s, patient.familyName, patient.givenNames.first, de_index, de._type, description, de.dataElementCodes.first.code, ranks.join(','), other_time.to_date.to_s]
          end
        end
      end
    end
  end

  def other_data_element_time(data_element)
    return data_element.relevantPeriod.low if data_element['relevantPeriod']&.low
    return data_element.relevantDatetime if data_element['relevantDatetime']
    return data_element.prevalencePeriod.low if data_element['prevalencePeriod']&.low
    return data_element.resultDatetime if data_element['resultDatetime']
    return data_element.sentDatetime if data_element['sentDatetime']
    return data_element.participationPeriod.low if data_element['participationPeriod']
    return data_element.birthDatetime if data_element['birthDatetime']
    nil
  end


  task :shift_entries, [:bundle_version] => :setup do |_, args|
    bundle = Bundle.where(version: args.bundle_version).first
    # Set up ecm-execution
    effective_date_end = Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number)
    effective_date = Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDateEnd': effective_date_end, 'effectiveDate': effective_date }
    impacted_cals = 0
    bundle.patients.each_with_index do |patient, p_index|
      puts "patient index - #{p_index}"
      patient.qdmPatient.shift_dates(0)
      patient.save
      earliest_jan_date = patient.qdmPatient.dataElements.map { |de| data_element_time(de).day if data_element_time(de).month == 1 && data_element_time(de).year != 2030 }.compact.min
      latest_dec_date = patient.qdmPatient.dataElements.map { |de| data_element_time(de).day if data_element_time(de).month == 12 && data_element_time(de).year != 2030 }.compact.max
      earliest_shift = earliest_jan_date.nil? ? 29 : (earliest_jan_date - 1)
      latest_shift = latest_dec_date.nil? ? 30 : (30 - latest_dec_date)
      date_shift = 86400 * Random.rand((-1 * earliest_shift)..latest_shift)
      cw_patient = ProductTestPatient.new(patient.attributes.except('_id', '_type', 'providers'))
      cw_patient.qdmPatient = patient.qdmPatient.clone
      cw_patient.qdmPatient.shift_dates(date_shift)
      cw_patient.save
      calc_diffs = false
      bundle.measures.each_with_index do |measure, m_index|
        break if calc_diffs
        next unless patient.patient_relevant?([measure.id], ['IPP'])
        # puts "measure index - #{m_index}"
        original_results = SingleMeasureCalculationJob.perform_now([patient.id.to_s], measure.id.to_s, bundle.id.to_s, options)
        cw_results = SingleMeasureCalculationJob.perform_now([cw_patient.id.to_s], measure.id.to_s, bundle.id.to_s, options)
        calc_diffs = dev_are_results_different?(original_results, cw_results)
      end
      impacted_cals += 1 if calc_diffs
      puts "I'm impacted - #{patient.id} - #{patient.familyName} #{patient.givenNames.first}" if calc_diffs
      unless calc_diffs
        patient.qdmPatient.shift_dates(date_shift)
        patient.save
      end
      cw_patient.delete
    end
    puts impacted_cals
  end

  task :shift_forward, [:bundle_version] => :setup do |_, args|
    bundle = Bundle.where(version: args.bundle_version).first
    offset = (Time.at(bundle.measure_period_start).in_time_zone + 1.year).to_i - bundle.measure_period_start
    bundle.patients.each do |patient|
      patient.qdmPatient.shift_dates(offset)
      patient.save
    end
  end

  task :download_all, [:bundle_version] => :setup do |_, args|
    bundle = Bundle.where(version: args.bundle_version).first
    path = Rails.root.join('tmp', bundle.id.to_s)
    Cypress::CreateDownloadZip.bundle_directory(bundle, path)
    zfg = ZipFileGenerator.new(path, bundle.mpl_path)
    zfg.write
  end

  BUNDLE_ROOTS = { directory: '/Users/dczulada/Desktop/Code/Cypress/bundles/bundles/cypress_7/2024/patients'}
  task :download_all_json_from_dir, [:bundle_version] => :setup do |_, args|
    bundle = Bundle.where(version: args.bundle_version).first
    Dir.chdir(BUNDLE_ROOTS[:directory]) do
      Dir.glob("**/*.xml") do |patient_file|
        puts "working on: #{patient_file}..."
        qrda_file = File.open(patient_file)
        qrda = qrda_file.read
        doc = Nokogiri::XML::Document.parse(qrda)
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        patient, _warnings, codes = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
        Cypress::QrdaPostProcessor.remove_unmatched_data_type_code_combinations(patient, bundle)
        byebug
      end
    end
  end

  task :download_all_json, [:bundle_version] => :setup do |_, args|
    bundle = Bundle.where(version: args.bundle_version).first
    measure = bundle.measures.find_by(cms_id: 'CMS2v14')

    measure_set_id = measure.hqmf_set_id
    qdm_version = '5.6'
    qdm_version_file = qdm_version.gsub '.', ''
    created_at = Time.now.to_i
    base_file_name = "patients_#{measure_set_id}_QDM_#{qdm_version_file}_#{created_at}"

    patients = []
    Dir.chdir(BUNDLE_ROOTS[:directory]) do
      Dir.glob("**/*.xml") do |patient_file|
        puts "working on: #{patient_file}..."
        qrda_file = File.open(patient_file)
        qrda = qrda_file.read
        doc = Nokogiri::XML::Document.parse(qrda)
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        patient, _warnings, codes = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
        Cypress::QrdaPostProcessor.remove_unmatched_data_type_code_combinations(patient, bundle)
        patients << patient
      end
    end

    patient_json_array = []

    patient_count = patients.count

    patients.each do |patient|
      # patient.notes = patient.measure_relevance_hash[measure.id.to_s].to_s
      # if patient.notes != ""
      #   patient.expectedValues = [{ "DENEX": patient.measure_relevance_hash[measure.id.to_s]['DENEX'],
      #                               "DENOM": patient.measure_relevance_hash[measure.id.to_s]['DENOM'],
      #                               "IPP": patient.measure_relevance_hash[measure.id.to_s]['IPP'],
      #                               "NUMER": patient.measure_relevance_hash[measure.id.to_s]['NUMER'],
      #                               "NUMEX": patient.measure_relevance_hash[measure.id.to_s]['NUMEX'],
      #                               "DENEXCEP": patient.measure_relevance_hash[measure.id.to_s]['DENEXCEP'],
      #                               "population_index": 0 }]
      # else
        patient.expectedValues = [{ "DENEX": 0,
                                    "DENOM": 0,
                                    "IPP": 0,
                                    "NUMER": 0,
                                    "NUMEX": 0,
                                    "DENEXCEP": 0,
                                    "population_index": 0 }]
      # end
      patient_json = patient.to_json(except: ['_id', 'addresses', 'code_description_hash', 'codes_modifiers', 'correlation_id', 'file_name',
                                              'created_at', 'email','measure_relevance_hash', 'medical_record_number', 'medicare_beneficiary_identifier', 'original_medical_record_number', 'original_patient_id', 'reported_measure_hqmf_ids', 'telecoms', 'updated_at',
                                              'measure_ids', 'measure_id', 'group_id', 'bundleId'])
      patient_json_array.push(patient_json)
    end

    bonnie_version = '5.1.5'
    patients_json = '[' + patient_json_array.join(',') + ']'
    patients_signature = Digest::MD5.hexdigest("#{qdm_version}#{patients_json}")

    measure_populations_json = measure.population_criteria.keys.to_json

    meta_json = "{" \
              "\"bonnie_version\":\"#{bonnie_version}\"," \
               "\"qdm_version\":\"#{qdm_version}\"," \
               "\"measure_set_id\":\"#{measure_set_id}\"," \
               "\"created_by\":\"#{"dczulada@mitre.org"}\"," \
               "\"created_at\":\"#{created_at}\"," \
               "\"measure_populations\":#{measure_populations_json}," \
               "\"patient_count\":\"#{patient_count}\"," \
               "\"patients_signature\":\"#{patients_signature}\"" \
    "}"

    begin
      temp_file = File.open("tmp/" + base_file_name + ".zip", "w")

      Zip::ZipOutputStream.open(temp_file.path) do |zos|
        zos.put_next_entry(base_file_name + ".json")
        zos.print patients_json
        zos.put_next_entry("#{base_file_name}_meta.json")
        zos.print meta_json
      end

    ensure
      temp_file.close # The temp file will be deleted some time...
    end
  end

  task :patients_with_events_before_birth, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    # CSV.open("tmp/#{args.bundle.gsub('.','_')}_only_author_time.csv", 'w', col_sep: '|') do |csv|
      bundle.patients.sort_by { |patient| "#{patient.familyName}_#{patient.givenNames.first}" }.each_with_index do |patient, index|
        patient.qdmPatient.dataElements.each_with_index do |de, de_index|
          next if ["QDM::PatientCharacteristicPayer"].include? de._type
          birth_time = patient.qdmPatient.birthDatetime
          de_time = data_element_time(de)

          puts "#{patient.familyName} #{patient.givenNames.first} (#{de.dataElementCodes.first.code}) - #{birth_time} - #{patient.id.to_s}" if de_time < birth_time
        end
      end
    # end
  end

  def self.data_element_time(data_element)
    return data_element.relevantPeriod.low if data_element['relevantPeriod']&.low
    return data_element.relevantDatetime if data_element['relevantDatetime']
    return data_element.prevalencePeriod.low if data_element['prevalencePeriod']&.low
    return data_element.authorDatetime if data_element['authorDatetime']
    return data_element.resultDatetime if data_element['resultDatetime']
    return data_element.sentDatetime if data_element['sentDatetime']
    return data_element.participationPeriod.low if data_element['participationPeriod']
    return data_element.birthDatetime if data_element['birthDatetime']
    return data_element.expiredDatetime if data_element['expiredDatetime']
    return Date.new(2030,1,1) #if ['QDM::PatientCharacteristicEthnicity', 'QDM::PatientCharacteristicRace', 'QDM::PatientCharacteristicSex'].include?(data_element._type)
  end

  desc %(
    Upload precalculate bundle file with extension .zip
  )
  task :negated_vs, [:bundle] => :setup do |_, args|
    bundle = Bundle.find_by version: args.bundle
    measures = {}
    valuesets = {}
    csv_text = File.read("script/#{args.bundle.split('.')[0]}.csv")
    csv = CSV.parse(csv_text, headers: true)
    csv.each do |row|
      measures[row[0]] = { valuesets: [] } unless measures[row[0]]
      measures[row[0]].valuesets << row[1]
      valuesets[row[1]] = { codes: [], overlapping_vs: [], overlapping_codes: {} }
    end
    valuesets.each_key do |oid|
      vs = bundle.value_sets.where(oid: oid).first
      valuesets[oid][:codes] = vs.concepts.collect(&:code)
    end
    valuesets.each do |oid, vs_hash|
      valuesets.each_key do |other_oid|
        next if oid == other_oid
        codes = [vs_hash[:codes].first]
        other_codes = valuesets[other_oid][:codes]
        intesection = codes & other_codes
        vs_hash[:overlapping_vs] <<  other_oid unless intesection.blank?
        vs_hash[:overlapping_codes][other_oid] = intesection unless intesection.blank?
      end
    end
    CSV.open("tmp/#{args.bundle.split('.')[0]}_overlap.csv", 'w', col_sep: '|') do |csv|
      valuesets.sort.each  do |oid, vs_hash|
        vs_hash[:overlapping_codes].each do |other_oid, codes|
          codes.each do |code|
            oid1_keys = measures.filter { |m, v| v.valuesets.include?(oid) }.keys
            oid2_keys = measures.filter { |m, v| v.valuesets.include?(other_oid) }.keys
            csv << [oid, oid1_keys, other_oid, oid2_keys, code]
          end
        end
      end
    end
  end

  task user_stats: :setup do
    month_start = Date.new(2021,10,1)
    month_end = Date.new(2021,10,31)
    total_count = User.all.size
    months = [1,2,3,4,5,6,7,8,9,10,11,12]
    count_hash = { 'Jan' => 0, 'Feb' => 0, 'Mar' => 0, 'Apr' => 0, 'May' => 0, 'Jun' => 0, 'Jul' => 0, 'Aug' => 0, 'Sep' => 0, 'Oct' => 0, 'Nov' => 0, 'Dec' => 0, }
    active_user_hash = {}

    User.all.each do |user|
      months.each do |month|
        month_start = Date.new(2021,month,1)
        month_end = if month == 12 
          Date.new(2021,12,31)
        else 
          Date.new(2021,month+1,1)
        end
        if user.current_sign_in_at
          if ((user.current_sign_in_at > month_start) && (user.current_sign_in_at < month_end))
            count_hash[month_start.strftime('%b')] += 1
            active_user_hash[user.id.to_s] = { sign_in_count: user.sign_in_count, last: month_start.strftime('%b') }
          end
        elsif user.last_sign_in_at
          if ((user.last_sign_in_at > month_start) && (user.last_sign_in_at < month_end))
            count_hash[month_start.strftime('%b')] += 1
            active_user_hash[user.id.to_s] = { sign_in_count: user.sign_in_count, last: month_start.strftime('%b') }
          end
        end
      end
    end
    count = 1
    active_user_hash.sort_by { |k,v| v[:sign_in_count] }.reverse.each do |auh|
      next if count > 20
      puts "#{auh[0]} - #{auh[1][:sign_in_count]} - #{auh[1][:last]}"
      count += 1
    end
    active_user_counts = active_user_hash.values.map(&:sign_in_count)
    # puts active_user_counts.sort.reverse![0,20]
    puts "Total_count - #{active_user_counts.sum}"
    count_hash.each do |mon, value|
      puts "#{mon} - #{value}"
    end
  end

  task :timezone_crosswalk, [:bundle_version] => :setup do |_, args|
    bundle = Bundle.where(version: args.bundle_version).first
    # Set up ecm-execution
    effective_date_end = Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number)
    effective_date = Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDateEnd': effective_date_end, 'effectiveDate': effective_date }
    bundle.measures.each_with_index do |measure, m_index|
      next if m_index > 62
      puts "measure index - #{m_index}"
      # next unless measure.cms_id == "CMS190v11"
      bundle.patients.each_with_index do |patient, p_index|
        # next unless patient.id.to_s == '626fce8ac1c3888961e5de37'
        ts = Time.now
        CSV.open('tmp/timezone_crosswalk.csv', 'a', col_sep: '|') do |csv|
          next unless patient.patient_relevant?([measure.id], ['IPP'])
          patient.qdmPatient.shift_dates(0)
          patient.save
          original_results = SingleMeasureCalculationJob.perform_now([patient.id.to_s], measure.id.to_s, bundle.id.to_s, options)
          calc_diffs = false
          [1, 2, 3, 4, 5, 6, 7, 8].each do |time_zone|
            cw_patient = ProductTestPatient.new(patient.attributes.except('_id', '_type', 'providers'))
            begin
              patient.qdmPatient.shift_dates(time_zone * 60 * 60)
              cw_patient.qdmPatient = patient.qdmPatient.clone
              patient.qdmPatient.shift_dates(time_zone * 60 * 60 * -1)
            rescue => e
              byebug
            end
            cw_patient.save
            cw_results = SingleMeasureCalculationJob.perform_now([cw_patient.id.to_s], measure.id.to_s, bundle.id.to_s, options)
            calc_diffs = dev_are_results_different?(original_results, cw_results)
            # Clean up by removing cloned patient
            cw_patient.delete
            # Log information about the crosswalk
            # byebug if calc_diffs
            csv << [measure.cms_id, "#{patient.givenNames[0]} #{patient.familyName}", time_zone] if calc_diffs
          end
        end
        te = Time.now
        puts "patient index - #{p_index} - #{te - ts}"
      end
    end
  end

  def path_hashes_from_def(elm)
    path_hashes = []
    path_expressions = elm.xpath(".//elm:operand[@xsi:type='Property'] | .//elm:code[@xsi:type='Property'] | .//elm:value[@xsi:type='Property'] | .//elm:expression[@xsi:type='Property'] | .//elm:source[@xsi:type='Property']")
    path_expressions.each do |path_expression|
      path_hashes << { path: path_expression['path'], scope: path_expression['scope'], localId: path_expression['localId'] }
    end
    path_hashes
  end

  def data_type_hashes_from_def(elm)
    data_type_hashes = []
    data_type_operands = elm.xpath(".//elm:operand[@xsi:type='Retrieve'] | .//elm:expression[@xsi:type='Retrieve']")
    data_type_operands.each do |data_type_operand|
      next unless data_type_operand.at_xpath('elm:codes')
      vs_name = data_type_operand.at_xpath('elm:codes')['name']
      vs_name ||= data_type_operand.at_xpath('elm:codes/elm:operand')['name']
      data_type_hashes << { dataType: data_type_operand['dataType'].split(":")[1], vs_name: vs_name, attributes: [] }
    end
    data_type_hashes
  end

  def function_hashes_from_def(elm, data_type_hashes)
    function_hashes = []
    function_expressions = elm.xpath(".//elm:operand[@xsi:type='FunctionRef'] | .//elm:value[@xsi:type='FunctionRef']")
    function_expressions.each do |function_expression|
      function_alias_expression = function_expression.xpath("./elm:operand[@xsi:type='AliasRef']").first
      function_dt_expression = function_expression.xpath("./elm:operand[@xsi:type='Retrieve']").first
      function_op_expression = function_expression.xpath("./elm:operand[@xsi:type='OperandRef']").first
      # byebug if function_expression['name'] == 'Normalize Abatement'
      if function_alias_expression
        function_hashes << { alias: true, scope: function_alias_expression['name'], function: function_expression['name'], og_expression: elm }
      elsif function_dt_expression
        dt = function_dt_expression['dataType'].split(":")[1]
        next unless function_dt_expression.at_xpath('elm:codes')
        vs_name = function_dt_expression.at_xpath('elm:codes')['name']
        vs_name ||= function_dt_expression.at_xpath('elm:codes/elm:operand')['name']
        data_type_hash = data_type_hashes.select { |dth| dth[:dataType] == dt && dth[:vs_name] == vs_name }.first
        function_hashes << { alias: false, scope: data_type_hash, function: function_expression['name'], og_expression: elm }
      elsif function_op_expression
        # byebug
        # find who calls this function
        function_hashes << { alias: true, scope: function_op_expression['name'], function: function_expression['name'], og_expression: elm }
      end
    end
    function_hashes
  end

  def follow_expression_ref(elm, data_type_hashes, dependencies_elm, path_hash, data_model_hash)
    referenced_expression = dependencies_elm["#{elm['libraryName']}#{elm['name']}"]
    return unless referenced_expression
    data_type_expressions = referenced_expression[:elm].xpath(".//elm:expression[@xsi:type='Retrieve'] | .//elm:operand[@xsi:type='Retrieve']")
    data_type_expressions.each do |data_type_expression|
      dt = data_type_expression['dataType'].split(":")[1]
      next unless data_type_expression.at_xpath('elm:codes')
      vs_name = data_type_expression.at_xpath('elm:codes')['name']
      vs_name ||= data_type_expression.at_xpath('elm:codes/elm:operand')['name']
      hash_to_update  = data_type_hashes.select { |dth| dth[:dataType] == dt && dth[:vs_name] == vs_name }.first
      # TODO: 
      # byebug if hash_to_update[:vs_name] == 'Ejection Fraction' && path_hash[:path] == 'prevalencePeriod'
      hash_to_update[:attributes] << data_type_expression['codeProperty'] unless hash_to_update[:attributes].include?(data_type_expression['codeProperty'])
      next unless attribute_appropriate_for_dt(hash_to_update[:dataType], path_hash[:path], data_model_hash)
      hash_to_update[:attributes] << path_hash[:path] unless hash_to_update[:attributes].include?(path_hash[:path]) if hash_to_update
    end
    exp_ref_expressions = referenced_expression[:elm].xpath(".//elm:expression[@xsi:type='ExpressionRef'] | .//elm:operand[@xsi:type='ExpressionRef']")
    exp_ref_expressions.each do |exp_ref_expression|
      follow_expression_ref(exp_ref_expression, data_type_hashes, dependencies_elm, path_hash, data_model_hash)
    end
  end

  def attribute_appropriate_for_dt(data_type, attribute, data_model_hash)
    data_model_hash[data_type].include?(attribute)
  end

  def types_from_model_info(filename)
    data_types = {}
    doc = File.open("tmp/#{filename}") { |f| Nokogiri::XML(f) }
    doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    doc.root.add_namespace_definition('elm', 'urn:hl7-org:elm-modelinfo:r1')
    types = doc.xpath("//elm:typeInfo")
    2.times do
      types.each do |type|
        type_name = type['name'].include?('QDM.') ? type['name'].split('.')[1] : type['name']
        data_types[type_name] = []
        attributes = type.xpath('elm:element')
        attributes.each do |att|
          data_types[type_name] << att['name']
        end
        base_type = type['baseType'].include?('QDM.') ? type['baseType'].split('.')[1] : type['baseType']
        data_types[type_name].concat(data_types[base_type]) if data_types[base_type]
      end
    end
    data_types
  end

  task :get_elm, [:bundle] => :setup do |_, args|
    bundle = args.bundle
    generate_elm_data_csv(bundle)
  end

  def generate_elm_data_csv(bundle)    
    model_info_file = bundle == 'fhir' ? 'fhir-modelinfo-4.0.1.xml' : 'qdm-modelinfo-5.6.xml'
    data_model_hash = types_from_model_info(model_info_file)
    measure_list = get_files_from_bundle(bundle)
    measure_list.each do |measure|
      folder = measure[:measure_folder]
      files = measure[:supporting_files]
      root_file = measure[:root]
      dependencies = []
      dependencies_elm = {}
      data_type_hashes = []
      function_hashes = []

      # next unless root_file == 'BreastCancerScreeningsFHIR.xml'

      # Get dependencies from root file
      doc = File.open("tmp/measures/#{bundle}/#{folder}/#{root_file}") { |f| Nokogiri::XML(f) }
      doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      doc.root.add_namespace_definition('elm', 'urn:hl7-org:elm:r1')
      root_def_expressions = doc.xpath("//elm:statements/elm:def")
      root_def_expressions.each do |root_def_expression|
        dependencies << root_def_expression['name']
        dependencies_elm[root_def_expression['name']] = { elm: root_def_expression, path_hashs: path_hashes_from_def(root_def_expression) }
        data_type_hashes.concat(data_type_hashes_from_def(root_def_expression))
        function_hashes.concat(function_hashes_from_def(root_def_expression, data_type_hashes))
      end
      dependency_expressions = doc.xpath("//elm:operand[@xsi:type='ExpressionRef'] | //elm:operand[@xsi:type='FunctionRef'] | //elm:expression[@xsi:type='ExpressionRef'] | //elm:expression[@xsi:type='FunctionRef']")
      dependency_expressions.each do |dependency_expression|
        dependencies << dependency_expression['name'] unless dependencies.include?(dependency_expression['name'])
      end

      # Follow dependencies into supporting files 
      dependencies.each_with_index do |dependency, dep_index|
        next unless dependency
        files.each_with_index do |file_name, index|
          doc = File.open("tmp/measures/#{bundle}/#{folder}/#{file_name}") { |f| Nokogiri::XML(f) }
          doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
          doc.root.add_namespace_definition('elm', 'urn:hl7-org:elm:r1')

          if dependency.include?("'")
            puts dependency
            next
          end
          library_name = doc.at_xpath("//elm:library/elm:identifier/@id").value
          def_expression = doc.xpath("//elm:library/elm:statements/elm:def[@name='#{dependency}']").first
          if def_expression
            dependencies_elm["#{library_name}#{dependency}"] = { elm: def_expression, path_hashs: path_hashes_from_def(def_expression) }
            data_type_hashes.concat(data_type_hashes_from_def(def_expression))
            function_hashes.concat(function_hashes_from_def(def_expression, data_type_hashes))
            dependency_expressions = def_expression.xpath(".//elm:operand[@xsi:type='ExpressionRef'] | .//elm:operand[@xsi:type='FunctionRef'] | .//elm:expression[@xsi:type='ExpressionRef'] | .//elm:expression[@xsi:type='FunctionRef']")
            dependency_expressions.each do |dependency_expression|
              dependencies << dependency_expression['name'] unless dependencies.include?(dependency_expression['name'])
            end
          end
        end
      end
      data_type_hashes = data_type_hashes.uniq

      dependencies_elm.each do |key, def_expression_hash|
        if def_expression_hash[:path_hashs].empty?
          data_type_expressions = def_expression_hash[:elm].xpath(".//elm:expression[@xsi:type='Retrieve'] | .//elm:operand[@xsi:type='Retrieve']")
          data_type_expressions.each do |data_type_expression|
            dt = data_type_expression['dataType'].split(":")[1]
            next unless data_type_expression.at_xpath('elm:codes')
            vs_name = data_type_expression.at_xpath('elm:codes')['name']
            vs_name ||= data_type_expression.at_xpath('elm:codes/elm:operand')['name']
            hash_to_update  = data_type_hashes.select { |dth| dth[:dataType] == dt && dth[:vs_name] == vs_name }.first
            hash_to_update[:attributes] << data_type_expression['codeProperty'] unless hash_to_update[:attributes].include?(data_type_expression['codeProperty'])
          end
        end
        def_expression_hash[:path_hashs].each do |path_hash|
          def_expression = def_expression_hash[:elm]

          alias_expression = def_expression.xpath(".//elm:source[@alias='#{path_hash[:scope]}'] | .//elm:relationship[@alias='#{path_hash[:scope]}']")
          data_type_expressions = alias_expression.xpath(".//elm:expression[@xsi:type='Retrieve'] | .//elm:operand[@xsi:type='Retrieve']")
          data_type_expressions.each do |data_type_expression|
            dt = data_type_expression['dataType'].split(":")[1]
            next unless data_type_expression.at_xpath('elm:codes')
            vs_name = data_type_expression.at_xpath('elm:codes')['name']
            vs_name ||= data_type_expression.at_xpath('elm:codes/elm:operand')['name']
            hash_to_update  = data_type_hashes.select { |dth| dth[:dataType] == dt && dth[:vs_name] == vs_name }.first
            hash_to_update[:attributes] << data_type_expression['codeProperty'] unless hash_to_update[:attributes].include?(data_type_expression['codeProperty'])
            next unless attribute_appropriate_for_dt(hash_to_update[:dataType], path_hash[:path], data_model_hash)
            hash_to_update[:attributes] << path_hash[:path] unless hash_to_update[:attributes].include?(path_hash[:path])
          end

          is_function = def_expression.at_xpath('@xsi:type') && def_expression.at_xpath('@xsi:type').value == 'FunctionDef'
          # byebug if is_function

          exp_ref_expressions = alias_expression.xpath(".//elm:expression[@xsi:type='ExpressionRef'] | .//elm:operand[@xsi:type='ExpressionRef']")
          exp_ref_expressions.each do |exp_ref_expression|
            follow_expression_ref(exp_ref_expression, data_type_hashes, dependencies_elm, path_hash, data_model_hash)
          end
        end
      end
      CSV.open("tmp/data_requirements/#{root_file}.csv", 'w', col_sep: '|') do |csv|
        data_type_hashes.each do |data_type_hash|
          # csv << [data_type_hash[:dataType],data_type_hash[:vs_name], 'code']
          data_type_hash[:attributes].each do |attribute|
            csv << [data_type_hash[:dataType],data_type_hash[:vs_name], attribute]
          end
        end
      end
      CSV.open("tmp/data_requirements/#{bundle}_all.csv", 'a', col_sep: '|') do |csv|
        data_type_hashes.each do |data_type_hash|
          # csv << [folder, data_type_hash[:dataType],data_type_hash[:vs_name], 'code']
          data_type_hash[:attributes].each do |attribute|
            csv << [root_file, data_type_hash[:dataType],data_type_hash[:vs_name], attribute]
          end
        end
      end
    end
  end

  task :get_dr, [:bundle_version] => :setup do |_, args|
    qdm_map = getting_qdm_mappings
    bundle = Bundle.where(version: args.bundle_version).first
    vs_hash = bundle.value_sets.map { |vs| [vs['oid'], vs['display_name'] ] }.to_h
    CSV.open("tmp/data_requirements_mapping_v7.csv", 'w', col_sep: '|') do |csv|
      bundle.measures.each do |measure|
        measure.source_data_criteria.each_with_index do |sdc, index|
          if sdc.qdmCategory == 'patient_characteristic'
            pc_maps = { 'gender' => 'Sex', 'payer' => 'Payer', 'race' => 'Race', 'ethnicity' => 'Ethnicity', 'expired' => 'Expired', 'birthdate' => 'Birthdate' }
            mapped_pc = if sdc.dataElementAttributes.empty?
                          qdm_map.select { |qdm| qdm[:qdm_concept].include?(pc_maps[sdc.qdmStatus]) }.first
                        else
                          att_name = sdc.dataElementAttributes[0]['attribute_name']
                          att_name = 'expirationdatetime' if att_name == 'expiredDatetime'
                          qdm_map.select { |qdm| qdm[:qdm_concept].include?(pc_maps[sdc.qdmStatus]) && qdm[:qdm_attribute].include?(att_name) }.first
                        end
            csv << [measure.cms_id, index, sdc.qdmTitle, sdc.qdmStatus, '', '', mapped_pc[:qi_profile], mapped_pc[:qi_field], mapped_pc[:us_core], mapped_pc[:resource] ]
          else
            mapped_code = qdm_map.select { |qdm| qdm[:qdm_concept].include?(sdc.qdmTitle) && qdm[:qdm_attribute] == 'code' }.first
            # byebug
            if mapped_code
              csv << [measure.cms_id, index, sdc.qdmTitle, 'code', vs_hash[sdc.codeListId], sdc.codeListId, mapped_code[:qi_profile], mapped_code[:qi_field], mapped_code[:us_core], mapped_code[:resource] ]
            else
              csv << [measure.cms_id, index, sdc.qdmTitle, 'code', vs_hash[sdc.codeListId], sdc.codeListId]
            end
            context_items = qdm_map.select { |qdm| qdm[:qdm_concept].include?(sdc.qdmTitle) && qdm[:qdm_attribute] == 'QDMContext'.downcase }
            context_items.each do |context_item|
              csv << [measure.cms_id, index, sdc.qdmTitle, '', '', '', context_item[:qi_profile], context_item[:qi_field], context_item[:us_core], context_item[:resource] ]
            end
            sdc.dataElementAttributes.each do |dea|
              mapped_item = qdm_map.select { |qdm| qdm[:qdm_concept].include?(sdc.qdmTitle) && qdm[:qdm_attribute] == mapped_dea_attribute_name(dea).downcase }.first
              att_vs_name = vs_hash[dea.attribute_valueset]
              att_vs_name = bundle.value_sets.where('concepts.code' => dea.attribute_valueset).first.display_name if att_vs_name.nil? && !dea.attribute_valueset.nil?
              if mapped_item
                # byebug if dea.attribute_name == "result" && sdc.qdmTitle == 'Procedure, Performed'
                csv << [measure.cms_id, index, sdc.qdmTitle, dea.attribute_name, att_vs_name, dea.attribute_valueset, mapped_item[:qi_profile], mapped_item[:qi_field], mapped_item[:us_core], mapped_item[:resource] ]
              else
                csv << [measure.cms_id, index, sdc.qdmTitle, dea.attribute_name, att_vs_name, dea.attribute_valueset]
              end
            end
          end
        end
      end
    end
  end

  def mapped_dea_attribute_name(dea)
    mapped_dea = { 'diagnoses' => 'diagnosis(code)' }
    return mapped_dea[dea.attribute_name] if mapped_dea[dea.attribute_name]
    dea.attribute_name.gsub(/ /, "")
  end

  task :test_dcab, [:bundle_versrion] => :setup do |_, args|
    bundle = Bundle.find_by(version: args.bundle_versrion)
    bundle.measures.each do |measure|
      measure.source_data_criteria.each do |sdc|
        next if sdc.qdmCategory == 'patient_characteristic'
        next unless sdc.dataElementAttributes.blank?
        puts "#{measure.cms_id} - #{sdc.description}"
      end
    end
  end

  def get_files_from_bundle(bundle)
    measure_list = []
    if bundle == 'qdm'
      Dir.foreach("tmp/measures/#{bundle}") do |measure_filename|
        next if measure_filename == '.' or measure_filename == '..' or measure_filename == '.DS_Store'
        file_hash = { measure_folder: measure_filename, root: '', supporting_files: [] }
        # Do work on the remaining files & directories
        Dir.foreach("tmp/measures/#{bundle}/#{measure_filename}") do |filename|
          next if filename == '.' or filename == '..' or measure_filename == '.DS_Store'
          if is_root_filename(filename, bundle)
            file_hash[:root] = filename
          elsif is_elm_filename(filename, bundle)
            file_hash[:supporting_files] << filename
          end
        end
        measure_list << file_hash
      end
    elsif bundle == 'fhir'
      Dir.foreach("tmp/measures/#{bundle}/measures") do |measure_filename|
        next if measure_filename == 'supporting' or measure_filename == '.' or measure_filename == '..' or measure_filename == '.DS_Store'
        file_hash = { measure_folder: "measures", root: measure_filename, supporting_files: [] }
        # Do work on the remaining files & directories
        Dir.foreach("tmp/measures/#{bundle}/measures/supporting") do |filename|
          next if filename == '.' or filename == '..' or measure_filename == '.DS_Store'
          file_hash[:supporting_files] << "supporting/#{filename}"
        end
        measure_list << file_hash
      end
    end
    measure_list
  end

  private

  def is_root_filename(filename, bundle)
    return true if (filename.include?('CMS') && filename.include?('xml') && filename.include?('QDM') && !filename.include?('eCQM'))
  end

  def is_elm_filename(filename, bundle)
    return true if (filename.include?('xml') && filename.include?('QDM') && !filename.include?('eCQM'))
  end

  def getting_qdm_mappings
    qdm_map = []
    csv_text = File.read("tmp/QDMtoQICore_v7.tsv")
    csv = CSV.parse(csv_text, headers: true, col_sep: "\t" )
    csv.each do |row|
      qdm_concept = row[0].nil? ? "" : row[0].strip
      qdm_attribute = row[2].nil? ? "" : row[2].strip
      qdm_attribute = 'QDMContext' if row[1] == 'C'
      next if qdm_attribute.include?("*")
      next if qdm_attribute.include?(qdm_concept)
      next if qdm_attribute == ""
      qi_profile = row[3].nil? ? "" : row[3].strip
      temp_qi_file = row[5].nil? ? "" : row[5].strip
      qi_field = temp_qi_file == "" ? row[4].strip : row[5].strip
      us_core = ['#N/A', '0'].include?(row[8]) ? "" : row[8]
      resource = ['#N/A', '0'].include?(row[11]) ? "" : row[11]
      qdm_map << { qdm_concept: qdm_concept, qdm_attribute: qdm_attribute.gsub(/ /, "").downcase, qi_profile: qi_profile, qi_field: qi_field, us_core: us_core, resource: resource }
    end
    qdm_map
  end

  def dev_are_results_different?(original_results, new_results)
    return true unless original_results
    original_results.each do |original_result|
      return true unless new_results
      new_result = new_results.select { |nr| nr['population_set_key'] == original_result.population_set_key }.first
      return true if dev_result_different?(original_result, new_result)
    end
    false
  end

  def dev_result_different?(original_result, new_result)
    return false if original_result.nil? || new_result.nil?
    return true unless original_result['DENEX'].to_i == new_result['DENEX'].to_i
    return true unless original_result['DENEXCEP'].to_i == new_result['DENEXCEP'].to_i
    return true unless original_result['DENOM'].to_i == new_result['DENOM'].to_i
    return true unless original_result['IPP'].to_i == new_result['IPP'].to_i
    return true unless original_result['MSRPOPL'].to_i == new_result['MSRPOPL'].to_i
    return true unless original_result['MSRPOPLEX'].to_i == new_result['MSRPOPLEX'].to_i
    return true unless original_result['NUMER'].to_i == new_result['NUMER'].to_i
    return true unless original_result['NUMEX'].to_i == new_result['NUMEX'].to_i
    return true unless original_result['OBSERV'].to_i == new_result['OBSERV'].to_i

    false
  end
end
# rubocop:enable all
