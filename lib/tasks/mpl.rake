require 'quality-measure-engine'
require 'measure_evaluator'



namespace :mpl do

  task :setup => :environment do
    @loader = QME::Database::Loader.new()
    @mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
    @template_dir = File.join(Rails.root, 'db', 'templates')
    @birthdate_dev = 60*60*24*7 # 7 days
    @evaluator = Cypress::MeasureEvaluator
  end
  
  desc 'Drop all patients and cached query results'
  task :clear  => :setup do
    @loader.drop_collection('records')
    @loader.drop_collection('query_cache')
    @loader.drop_collection('patient_cache')
    @loader.drop_collection('patient_populations')
  end
  
  desc 'Dump current contents of records collection to master patient list diretcory'
  task :dump => :setup do
    db = @loader.get_db
    db['records'].find().each do |record|
      file_name = File.join(@mpl_dir, "#{record['patient_id']}_#{record['first']}_#{record['last']}.json")
      file = File.new(file_name,  "w")
      file.write(JSON.pretty_generate(JSON.parse(record.to_json)))
      file.close
    end
  end

  desc 'Seed database with master patient list'
  task :load => [:setup, :clear] do
    mpls = File.join(@mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      if json['_id']
        json['_id'] = BSON::ObjectId.from_string(json['_id'])
      end
      @loader.save('records', json)
    end

    # put a few standard patient populations in 
    @loader.save('patient_populations', {:name => "all", :patient_ids => Array.new(225) {|i| i.to_s},
      :description => "Full Test Deck - 225 Records"})
    @loader.save('patient_populations', {:name => "core20", :patient_ids => [201,92,20,176,30,109,82,28,5,31,189,58,57,173,188,46,55,72,81,26].collect {|x| x.to_s},
      :description => "Core and Core Alternate Subset - 20 Records"})
  end
  
  desc 'Evaluate all measures for the entire master patient list'
  task :eval => :setup do
    db = @loader.get_db
    Measure.installed.each do |measure|
      puts 'Evaluating measure: ' + measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + ' - ' + measure['name']
      @evaluator.eval_for_static_records(measure)
    end
  end

  desc 'Evaluate all measures for the entire master patient list and dumps results to text file for diffing'
  task :eval_diff_file => :setup do
    db = @loader.get_db
    current_results = File.new(Rails.root.join("public","current_mpl_results.txt"), "w+")
    Measure.installed.each do |measure|
      result = @evaluator.eval_for_static_records(measure)
      current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["numerator"]:' + result['numerator'].to_s 
      current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["denominator"]:' + result['denominator'].to_s 
      current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["exclusions"]:' + result['exclusions'].to_s 
    end
  end

  desc 'Perform all tasks necessary for initializing a newly installed system'
  task :initialize => :setup do
    Rake::Task['mpl:clear'].invoke()
    Rake::Task['mpl:load'].invoke()
    Rake::Task['mpl:eval'].invoke()
  end



  desc 'Collect a subset of "count" patients that meet the criteria for the given set of "measures"'
  task :subset => :setup do
    measures = ENV['measures'].split(',')
    num_patients = ENV['count'] ? ENV['count'].to_i : 20
    
    verbose = ENV['verbose']
    intersection = []
    initialized = false
    patient_ids = {}
    Measure.installed.each do |measure|
      if measures.any? {|m| m == measure['id']}
        if verbose == "true"
          print 'Patients for measure ' + measure.key + ': '
	      end
	      
	      patients = Result.where('value.test_id' => nil).where('value.measure_id' => measure['id']).where('value.population' => true).each do |result|
	        if !patient_ids[measure['id']]
	          patient_ids[measure['id']] = []
	        end
	  
	        id = Record.find(result.value.patient_id).patient_id
	        patient_ids[measure['id']].push(id)

	        if verbose == "true"
	          print id + ' '
	        end
	      end
	      puts ''
      end
    end

    patient_ids.each do |k,v|
      ints = v.uniq.map {|e| e.to_i}
      v = ints.sort
      if intersection == []
        intersection = v
      else
        test = intersection & v
	      if test.count == 0
	        puts '!!! there is no intersection with ' + k + ' !!!'
	      else
          intersection = test 
	      end
      end
      
      if verbose == 'true' then
        puts '=== patient IDs for ' + k + ' ==='
        v.each do |id|
          print id.to_s + ' '
        end
        puts ''
      end
    end

    i = [num_patients,intersection.count].min
    puts 'Result (returning ' + i.to_s + ' of ' + intersection.count.to_s + ' records): '

    intersection.each do |id|
      i -= 1
      if i >= 0 then
      	 print id.to_s + ' '
      end
    end
    puts ''
  end
end
