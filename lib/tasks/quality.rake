# begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality)


  Cane::RakeTask.new(:quality_pre) do |cane|
    cane.abc_max = 30
    cane.style_measure = 240
    cane.no_doc = true
    cane.max_violations = 10
    cane.parallel
  end


  Cane::RakeTask.new(:quality_post) do |cane|
    cane.no_abc = true
    cane.no_doc = true
    cane.no_readme = true
    cane.no_style = true
    cane.add_threshold 'coverage/covered_percent', :>=, 77.38
  end

# rescue LoadError
#   warn "cane not available, quality task not provided."
# end
