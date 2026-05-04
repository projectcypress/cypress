# frozen_string_literal: true

class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  field :options, type: Hash
  field :expected_results, type: Hash
  field :latest_test_execution_id, type: String

  belongs_to :product_test, inverse_of: :tasks, touch: true
  has_many :test_executions, dependent: :destroy

  after_create :refresh_product_test_status
  after_destroy :remove_product_test_status

  delegate :start_date, to: :product_test
  delegate :end_date, to: :product_test
  delegate :measures, :measure_ids, to: :product_test
  delegate :patients, to: :product_test
  delegate :augmented_patients, to: :product_test
  delegate :effective_date, to: :product_test
  delegate :measure_period_start, to: :product_test
  delegate :bundle, to: :product_test
  delegate :name, :state, to: :product_test, prefix: true
  delegate :cms_id, :expected_results, to: :product_test, prefix: true

  %w[
    C1Task C1ChecklistTask C3ChecklistTask C2Task C3Cat1Task C3Cat3Task
    Cat1FilterTask Cat3FilterTask MultiMeasureCat1Task MultiMeasureCat3Task CMSProgramTask
  ].each do |task_type|
    # Define methods for fetching specific types of tasks,
    # for example (Task.c1_task, Task.cat1_filter_task, etc)
    define_singleton_method task_type.underscore do
      find_by(_type: task_type)
    rescue StandardError
      nil
    end
  end

  # Defines methods for checking task status (task.passing?, etc)
  %w[passing failing errored pending incomplete].each do |task_state|
    define_method "#{task_state}?" do
      status == task_state
    end
  end

  def status
    cached_status = product_test&.most_recent_task_status(_type)
    return cached_status if cached_status && _type != 'Task'

    Rails.cache.fetch("#{cache_key}/status") do
      computed_status
    end
  end

  def computed_status
    status_for_execution(most_recent_execution)
  end

  def status_for_execution(execution)
    return 'incomplete' unless execution

    if execution.passing?
      'passing'
    elsif execution.failing?
      'failing'
    elsif execution.errored?
      'errored'
    else # Test is not any of the above states but does exist, assume pending state
      'pending'
    end
  end

  # returns the most recent execution for this task
  # if there are none, returns nil
  def most_recent_execution
    # if latest_test_execution_id is stored, use it.  Else, look it up.
    if latest_test_execution_id
      TestExecution.find(latest_test_execution_id)
    else
      test_executions.any? ? test_executions.order_by(created_at: 'desc').limit(1).first : nil
    end
  end

  def refresh_product_test_status
    product_test.refresh_most_recent_task_status!(self)
  end

  def remove_product_test_status
    product_test.remove_most_recent_task_status!(self)
  end
end
