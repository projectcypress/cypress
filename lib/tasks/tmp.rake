require 'rails/tasks'

namespace :tmp do
  namespace :cache do
    # desc "Cleans and then rebuilds the cypress cache"
    task rebuild: [:environment] do
      puts 'Warming the vendor and product state cache...'
      Vendor.each(&:status)
    end

    desc "Rebuilds the MPL Download .zip for all installed bundles"
    task mpl_download_rebuild: [:environment] do
      puts 'Rebuilding all MPL Downloads...'
      Bundle.all.each do |bundle|
        puts "\tBuilding MPL download for bundle #{bundle.version}"
        MplDownloadCreateJob.perform_now(bundle.id)
      end
      puts 'done'
    end
  end
end

Rake::Task['tmp:cache:clear'].enhance do
  Rake::Task['tmp:cache:rebuild'].invoke
  Rake::Task['tmp:cache:mpl_download_rebuild'].invoke
end

Rake::Task['bundle:download_and_install'].enhance do
  Rake::Task['tmp:cache:mpl_download_rebuild'].invoke
end
