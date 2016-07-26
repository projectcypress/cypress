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

  def self.c1_task
    find_by(_type: 'C1Task')
  rescue
    false
  end

  def self.c1_manual_task
    find_by(_type: 'C1ManualTask')
  rescue
    false
  end

  def self.c3_manual_task
    find_by(_type: 'C3ManualTask')
  rescue
    false
  end

  def self.c2_task
    find_by(_type: 'C2Task')
  rescue
    false
  end

  def self.c3_cat1_task
    find_by(_type: 'C3Cat1Task')
  rescue
    false
  end

  def self.c3_cat3_task
    find_by(_type: 'C3Cat3Task')
  rescue
    false
  end

  def self.cat1_filter_task
    find_by(_type: 'Cat1FilterTask')
  rescue
    false
  end

  def self.cat3_filter_task
    find_by(_type: 'Cat3FilterTask')
  rescue
    false
  end

  def passing?
    status == 'passing'
  end

  def failing?
    status == 'failing'
  end

  def errored?
    status == 'errored'
  end

  def incomplete?
    status == 'incomplete'
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      recent_execution = most_recent_execution
      return 'incomplete' unless recent_execution
      if recent_execution.passing?
        'passing'
      elsif recent_execution.failing?
        'failing'
      elsif recent_execution.errored?
        'errored'
      else
        'incomplete'
      end
    end
  end

  # returns the most recent execution for this task
  # if there are none, returns nil
  def most_recent_execution
    test_executions.any? ? test_executions.order_by(created_at: 'desc').first : nil
  end
end
