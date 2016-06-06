namespace :cypress do
  namespace :cleanup do
    task :setup => :environment

    desc 'Remove temporary items (such as vendors, tests, etc) from the database, without removing existing users'
    task :database => :setup do
      print 'Cleaning database...'
      Delayed::Job.destroy_all
      before = Vendor.all.count
      Vendor.destroy_all
      diff = before - Vendor.all.count
      QME::QualityReport.destroy_all(test_id: { '$ne' => nil })
      Record.destroy_all(test_id: { '$ne' => nil })
      Artifact.destroy_all
      puts "removed #{diff} Vendors"
    end

    desc 'Get rid of files in tmp/cache'
    task :temp_files => :setup do
      print 'Cleaning temp files...'
      task('tmp:cache:clear').invoke
      Rails.cache.clear
      puts 'done'
    end

    task all: [:environment, :database, :temp_files]
  end
end
