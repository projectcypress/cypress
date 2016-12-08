require 'rails/tasks'

namespace :tmp do
  namespace :cache do
    # desc "Cleans and then rebuilds the cypress cache"
    task rebuild: [:environment] do
      puts 'Warming the vendor and product state cache...'
      Vendor.each(&:status)
    end
  end
end

Rake::Task['tmp:cache:clear'].enhance do
  Rake::Task['tmp:cache:rebuild'].invoke
end
