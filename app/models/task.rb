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

  # def status
  #   report_status = 'incomplete'
  #   statuses = [c1_c2_status]
  #   statuses << c3_status if product_test.product.c3_test
  #   report_status = 'failing' if statuses.any? { |stat| stat == 'failing' }
  #   report_status = 'passing' if statuses.all? { |stat| stat == 'passing' }
  #   report_status
  # end

  # def c1_c2_status
  #   Rails.cache.fetch("#{cache_key}/status") do
  #     report_status = 'incomplete'
  #     if test_executions.exists? && test_executions.count > 0
  #       recent_execution = test_executions.order_by(created_at: 'desc').first
  #       if recent_execution.passing?
  #         report_status = 'passing'
  #       elsif recent_execution.failing?
  #         report_status = 'failing'
  #       end
  #     end
  #     report_status
  #   end
  # end

  # # should only be used on c1 and c2 tasks
  # # should only be used if product.c3_test is true
  # def c3_status
  #   report_status = 'incomplete'
  #   if test_executions.exists? && test_executions.count > 0
  #     recent_execution = TestExecution.find(test_executions.order_by(created_at: 'desc').first.sibling_execution_id)
  #     if recent_execution.passing?
  #       report_status = 'passing'
  #     elsif recent_execution.failing?
  #       report_status = 'failing'
  #     end
  #   end
  #   report_status
  # end
end
