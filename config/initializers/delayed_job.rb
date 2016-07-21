Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
Delayed::Worker.logger.level = Logger::WARN
Delayed::Worker.destroy_failed_jobs = false
