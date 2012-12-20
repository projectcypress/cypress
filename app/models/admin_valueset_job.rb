class AdminValuesetJob

	include Mongoid::Document
	include Mongoid::Timestamps


	field :log_messages, type: Array, default: []
	field :processed_oids , type: Array, default: []
	field :status, type: String, default: "Waiting"
	field :total_length , type: Integer
	field :job_id, type: String
	field :failure_message, type: String, default: ""

  scope :ordered_by_date , order_by(:created_at => :desc)
	after_destroy do |obj|
		Delayed::Job.destroy(obj.job_id)
	end

  def update_valuesets(username, password, clear = false)
  	updater = Cypress::ValuesetUpdater.new({username: username, password: password, clear: clear,  logger: self})
  	updater.perform
  end

	def finished
	end

	def total_length=(tl)
		self[:total_length]=tl
		self.save
	end

	def processed(oid)
		self.processed_oids << oid
		log(:info, "Processed #{oid}")
	end

	def before(job, *args)
		puts "before"
		job_id = job.id 
		self.status = "Running"
		self.save
	end

	def after(job,*args)
		if job.last_error && status == "Waiting"
			self.failure_message = job.last_error
			self.save
		end

	end

	def success(job, *args)
		self.status = "Completed"
		self.save
	end

	def error(job, e)
		puts "error"
		self.status = "Failed"
		self.failure_message = e.message
		self.save
	end

	def log(type, message)
		self.log_messages ||= []
		self.log_messages << {type: type, message: message}
		self.save
	end

	def percentage_complete
		if total_length
			self.processed_oids.length / self.total_length
		else
			0
		end
	end

end