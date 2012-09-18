require 'quality-measure-engine'

namespace :cypress do
  task :tttt do
     puts ENV.inspect
  end

  task :setup => :environment

  desc 'Perform all tasks necessary for initializing a newly installed system'
  task :initialize => :setup do
    # Only use one of the initialize commands so we don't accidentally double evaluate all of the measures
    task("measures:download").invoke unless @local_installation
    task("measures:install").invoke
    task("mpl:initialize").invoke
  end
  
  desc 'Load a quality bundle into the database'
  task :import_bundle, [:bundle_path, :delete_existing] do |task, args|
    raise "The path to the measures zip file must be specified" unless args.bundle_path
    
    bundle = File.open(args.bundle_path)
    importer = QME::Bundle::Importer.new(args.db_name)
    importer.import(bundle, args.delete_existing)
  end
  
  desc "Delete all collections from the database related to the Cypress workflow (e.g. vendors, products, etc)"
  task :reset => :setup do
    # From the model dependencies, this will delete all Products, ProductTests, TestExecutions, and related Records
    Vendor.destroy_all
    
    db = Mongoid.master
    db.drop_collection('races')
    db.drop_collection('ethnicities')
    db.drop_collection('languages')
  end
end