class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, :type => String
  field :event, :type => String
  field :description, :type => String
  field :checksum, :type => String

  # Necessary fields for ATNA logging
  validates_presence_of :username
  validates_presence_of :event
  after_create :create_atna_log

  # After we save our log to the DB, we also write to the syslog to enable the IHE ATNA Record Audit
  def create_atna_log
    Atna.log(self.username, self.event)
  end
end
