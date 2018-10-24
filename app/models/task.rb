class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  field :options, type: Hash
  field :expected_results, type: Hash

  belongs_to :product_test, :inverse_of => :tasks, :touch => true
  has_many :test_executions, :dependent => :destroy
  delegate :start_date, :to => :product_test
  delegate :end_date, :to => :product_test
  delegate :measures, :measure_ids, :to => :product_test
  delegate :patients, :to => :product_test
  delegate :augmented_patients, :to => :product_test
  delegate :effective_date, :to => :product_test
  delegate :measure_period_start, :to => :product_test
  delegate :bundle, :to => :product_test
  delegate :name, :state, :to => :product_test, :prefix => true
  delegate :cms_id, :expected_results, :to => :product_test, :prefix => true

  %w[
    C1Task C1ChecklistTask C3ChecklistTask C2Task C3Cat1Task
    C3Cat3Task Cat1FilterTask Cat3FilterTask
  ].each do |task_type|
    # Define methods for fetching specific types of tasks,
    # for example (Task.c1_task, Task.cat1_filter_task, etc)
    define_singleton_method task_type.underscore do
      begin
        find_by(:_type => task_type)
      rescue
        false
      end
    end
  end

  # Defines methods for checking task status (task.passing?, etc)
  %w[passing failing errored pending incomplete].each do |task_state|
    define_method "#{task_state}?" do
      status == task_state
    end
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
      else # Test is not any of the above states but does exist, assume pending state
        'pending'
      end
    end
  end

  # returns the most recent execution for this task
  # if there are none, returns nil
  def most_recent_execution
    test_executions.any? ? test_executions.order_by(:created_at => 'desc').limit(1).first : nil
  end
end
