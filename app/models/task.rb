class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  field :options, type: Hash
  field :expected_results, type: Hash

  belongs_to :product_test, touch: true
  has_many :test_executions
  delegate :start_date, :to => :product_test
  delegate :end_date, :to => :product_test
  delegate :measures, :to => :product_test
  delegate :records, :to => :product_test

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      report_status = 'incomplete'
      if test_executions.exists? && test_executions.count > 0
        recent_execution = test_executions.order_by(created_at: 'desc').first
        if recent_execution.passing?
          report_status = 'passing'
        elsif recent_execution.failing?
          report_status = 'failing'
        end
      end
      report_status
    end
  end

  # returns the most recent execution for this task
  # if there are none, returns false
  def most_recent_execution
    return false unless test_executions.any?
    test_executions.order_by(created_at: 'desc').first
  end
end
