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
  delegate :effective_date, :to => :product_test
  delegate :bundle, :to => :product_test

  def passing?
    status == 'passing'
  end

  def failing?
    status == 'failing'
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      report_status = 'incomplete'
      recent_execution = most_recent_execution
      if recent_execution
        report_status = recent_execution.passing? ? 'passing' : 'failing'
      end
      report_status
    end
  end

  # returns the most recent execution for this task
  # if there are none, returns false
  def most_recent_execution
    test_executions.any? ? test_executions.order_by(created_at: 'desc').first : false
  end
end
