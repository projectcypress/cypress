class Tracker
  include Mongoid::Document
  field :job_id
  field :job_class, type: String
  field :status, type: Symbol
  field :log_message, type: Array, default: []

  scope :working, -> { where("status" => :working) }
  scope :failed, -> {where("status" => :failed )}
  scope :queued, -> { where("status" => :queued )}

  def log(data)
    log_message.push(data)
    save
  end

  def failed(error)
    status = :failed
    log(e.message)
  end

  def queued
    status = :queued
    log("queued")
  end


  def working
    status = :working
    log("working")
  end

  def finished
    status = :completed
    log("completed")
  end

end
