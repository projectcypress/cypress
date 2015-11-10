class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  field :options, type: Hash
  field :expected_results, type: Hash

  belongs_to :product_test, touch: true
  has_many :test_executions

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
      return_me = report_status
    end
  end
end
