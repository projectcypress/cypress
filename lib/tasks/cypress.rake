
require 'quality-measure-engine'
require 'measure_evaluator'


namespace :cypress do
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

  desc 'Perform all tasks necessary for initializing a newly installed system'
  task :initialize => :setup do
    #clear out everything
    Rake::Task['away:mpl_and_measures'].invoke()
    #clear out the measures, reload from ./db/bundle.zip
    Rake::Task['measures:update'].invoke()
    #load from ./db/master_patient_list
    Rake::Task['mpl:init'].invoke()
    Rake::Task['mpl:load'].invoke()
    #create results for test data
    Rake::Task['mpl:eval'].invoke()
  end
end
