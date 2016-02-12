class MeasureEvaluationJob < ActiveJob::Base
  queue_as :default

  def perform(bundle_file)
    bundle = File.open(bundle_file)
    importer = HealthDataStandards::Import::Bundle::Importer
    importer.import(bundle, {})
    if args.create_indexes != 'false'
      ::Rails.application.eager_load! if defined? Rails
      ::Mongoid::Tasks::Database.create_indexes
    end
  end
end
