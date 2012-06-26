#to update just the measures from remote:
#measures:reload_bundle M_VER=v1.4.2

#to update just the patients from remote:
#mpl:update

#to update patients and measures from local:
#measures:reload_local_bundle
#mpl:clear
#mpl:load

#to wipe everything and reload from local:
#mpl:initialize


require 'quality-measure-engine'
require 'measure_evaluator'
require 'patient_roll'

def download_patients(version)
   puts "downloading patients https://github.com/projectcypress/test-deck/zipball/#{version}"
   f =  open("https://github.com/projectcypress/test-deck/zipball/#{version}", :proxy=>ENV["http_proxy"])
   return f
end

namespace :mpl do
  task :tttt do
     puts ENV.inspect
  end

  task :setup => :environment do
    @loader = QME::Database::Loader.new()
    @mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
    @template_dir = File.join(Rails.root, 'db', 'templates')
    @birthdate_dev = 60*60*24*7 # 7 days
    @evaluator = Cypress::MeasureEvaluator
    @version = APP_CONFIG["mpl_version"]
  end
  
  desc 'MPL setup tasks'
  task :init => [:setup] do
    # put a few standard patient populations in 
    @loader.save('patient_populations', {:name => "all", :patient_ids => Array.new(225) {|i| i.to_s},
      :description => "Full Test Deck - 225 Records"})
    @loader.save('patient_populations', {:name => "core20", :patient_ids => [201,92,20,176,30,109,82,28,5,31,189,58,57,173,188,46,55,72,81,26].collect {|x| x.to_s},
      :description => "Core and Core Alternate Subset - 20 Records"})
  end

  desc 'Load only the mpl in the db directory'
  task :load  => [:setup] do
    puts "loading new master patient list into cypress"   
    mpls = File.join(@mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      if json['_id']
        json['_id'] = BSON::ObjectId.from_string(json['_id'])
      end
      @loader.save('records', json)
    end    
  end

  desc 'Remove the mpl currently loaded, drop query_cache and patient_cache'
  task :clear  => :setup do
    puts "removing current master patient list from cypress"
    db = @loader.get_db
    db['records'].remove("test_id" => nil)
    @loader.drop_collection('query_cache')
    @loader.drop_collection('patient_cache')
    
  end
  

  desc 'Download and reload only the master patient list and recalculate with currently loaded measures'
  task :update => [:setup,:clear] do
    puts "downloading master patient list"
    zip = download_patients(@version) 
    puts "unzipping master patient list"
    Zip::ZipFile.open(zip.path) do |zipfile|
     zipfile.each do |file|
      file_name = File.join(@mpl_dir, File.basename(file.name))
      if File.basename(file.name).include?(".json")        
        puts file_name
        zipfile.extract(file,file_name){true}
      end
     end
    end
    Rake::Task['mpl:load'].invoke()
    Rake::Task['mpl:eval'].invoke()
    
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

  
  
  desc 'Evaluate all measures for the entire master patient list'
  task :eval => :setup do
    db = @loader.get_db
    Measure.installed.each do |measure|
      puts 'Evaluating measure: ' + measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + ' - ' + measure['name']
      @evaluator.eval_for_static_records(measure,false)
    end
  end

  desc 'Evaluate all measures for the entire master patient list and dumps results to text file for diffing'
  task :eval_diff_file => :setup do
    db = @loader.get_db
    current_results = File.new(Rails.root.join("public","current_mpl_results.txt"), "w+")
    Measure.installed.each do |measure|
      result = @evaluator.eval_for_static_records(measure,false)
      current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["numerator"]:' + result['numerator'].to_s 
      current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["denominator"]:' + result['denominator'].to_s 
      current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["exclusions"]:' + result['exclusions'].to_s 
    end
  end

 
  
     desc 'Roll the date of every aspect of each patient forward or backwards [years, months, days] depending on sign'
 task :roll, :years, :months, :days, :start_date, :needs=> :setup do |t, args|
    args.with_defaults(:years => 0,  :start_date => false)
    if args[:start_date]
        Cypress::PatientRoll.roll_effective_date(args[:start_date])
    else
        Cypress::PatientRoll.roll_year(args[:years])
     end
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
