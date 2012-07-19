require 'quality-measure-engine'
require 'measure_evaluator'
require 'patient_zipper'
require 'pqri_utility'

namespace :test do
  namespace :round_trip do
    task :setup => :environment do
      @loader = QME::Database::Loader.new('cypress_test')
      @mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
      @evaluator = Cypress::MeasureEvaluator
    end

    desc 'Export master patient list to c32 zip file'
    task :export_zip, [:zip_path]  => [:load] do |t, args|
      path = args.zip_path
      puts args.zip_path
      if !args.zip_path
        puts 'Warning: Zip file not specified, using tmp/mpl_c32.zip'
        path = File.join(Rails.root, 'tmp', 'mpl_c32.zip')
      end
      format = 'c32'
      patients = Record.where("test_id" => nil)
      zip_file = File.new(path, 'w')
      Cypress::PatientZipper.zip(zip_file, patients, format.to_sym)
      zip_file.close
    end

    desc 'Check that pqri agrees with cypress. usage - rake round_trip:check_pqri[:measure_dir, :pqri_path]'
    task :check_pqri, [:measure_dir, :pqri_path] => [:load] do |t,args|
      measure_dir = args.measure_dir
      pqri_path = args.pqri_path
      if !args.pqri_path || !args.measure_dir
        puts 'Please specify a measure directory and a pqri file'
        puts 'usage - rake round_trip:check_pqri[:measure_dir, :pqri_path]'
        return
      end

      pqri_doc = Nokogiri::XML(File.new(args.pqri_path, 'r'))
      pqri_results = Cypress::PqriUtility.extract_results(pqri_doc, nil)

      ENV['MEASURE_PROPS'] = ENV['MEASURE_PROPS'] || args.measure_dir + '/measure_props'
      @loader.save_bundle(args.measure_dir,'measures')

      expected_results = Hash.new
      Measure.installed.each do |measure|
        key = measure.measure_id
        if measure.sub_id
          key = key + measure.sub_id
        end
        expected_results[key] = @evaluator.eval_for_static_records(measure,false)
      end

      if expected_results.count != pqri_results.count
        puts 'Warning, PQRI does not have same number of measures as Cypress. Only comparing the results of the measures given in PQRI.'
        puts 'PQRI result count:   ' + pqri_results.count
        puts 'Cypress result count:' + expected_results.count
      end

      pqri_results.each do |key,pqri_result|
        expected_result = expected_results[key]
        if pqri_result['numerator'] != expected_result['numerator']
          puts 'PQRI result:   ' + key.to_s + '[numerator]: ' + pqri_result['numerator'].to_s
          puts 'Cypress result:' + key.to_s + '[numerator]: ' + expected_result['numerator'].to_s
        end
        if pqri_result['denominator'] != expected_result['denominator']
          puts 'PQRI result:   ' + key +'[denominator]: '+ pqri_result['denominator'].to_s
          puts 'Cypress result:' + key +'[denominator]: '+ expected_result['denominator'].to_s
        end
        if pqri_result['exclusions'] != expected_result['exclusions']
          puts 'PQRI result:   ' + key +'[exclusions]: '+ pqri_result['exclusions'].to_s
          puts 'Cypress result:' + key +'[exclusions]: '+ expected_result['exclusions'].to_s
        end
      end
    end

    desc 'Drop all patients and cached query results'
    task :clear  => :setup do
      @loader.drop_collection('records')
      @loader.drop_collection('measures')
      @loader.drop_collection('query_cache')
      @loader.drop_collection('patient_cache')
      @loader.drop_collection('patient_populations')
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
    end
  end
end