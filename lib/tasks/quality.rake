# begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality)

  task :test_unit => :quality
# rescue LoadError
#   warn "cane not available, quality task not provided."
# end
