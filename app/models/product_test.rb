class ProductTest
  include Mongoid::Document

  belongs_to :product
  has_one :patient_population
  has_many :test_executions, dependent: :delete
  belongs_to :user
  belongs_to :bundle

  embeds_many :notes, inverse_of: :product_test

  # Test Details
  field :name, type: String
  field :description, type: String
  field :effective_date, type: Integer
  field :measure_ids, type: Array
  field :expected_results, type: Hash
  field :status_message, type: String

  validates_presence_of :name
  validates_presence_of :effective_date
  validates_presence_of :bundle_id

  scope :order_by_type, order_by(_type: desc)

  state_machine :state, :initial => :pending  do


   after_transition any => :ready do |test|
      test.status_message ="Ready"
      test.save
   end


   after_transition any => :errored do |test|
      test.status_message ="Error"
      test.save
   end

    event :ready do
      transition all => :ready
    end

    event :errored do
      transition all => :error
    end

  end


  def self.inherited(child)
    child.instance_eval do
      def model_name
        ProductTest.model_name
      end
    end
    super
  end

  def last_execution_date

  end

  # Returns true if this ProductTests most recent TestExecution is passing
  def execution_state
    return :pending if self.test_executions.empty?

    self.test_executions.ordered_by_date.first.state
  end

  def passing?
    execution_state == :passed
  end

  # Return all measures that are selected for this particular ProductTest
  def measures
    return [] if !measure_ids
    self.bundle.measures.in(:hqmf_id => measure_ids).order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end


  def records
    Record.where(:test_id => self.id).order_by([:last , :asc])
  end

  def delete
    # Gather all records and their IDs so we can delete them along with every associated entry in the patient cache
    records = Record.where(:test_id => self.id)
    record_ids = records.map { _id }
    MONGO_DB.collection('patient_cache').remove({'value.patient_id' => {"$in" => record_ids}})
    records.destroy
    self.destroy
  end

  # Get the expected result for a particular measure
  def expected_result(measure)
   (expected_results || {})[measure.key]
  end

  # Used for downloading and e-mailing the records associated with this test.
   #
   # Returns a file that represents the test's patients given the requested format.
  def generate_records_file(format)
     file = Tempfile.new("patients-#{Time.now.to_i}")
     patients = Record.where("test_id" => self.id)
     Cypress::PatientZipper.zip(file, patients, format.to_sym)

     file
  end

  def start_date
    Time.at(self.bundle['measure_period_start']).gmtime
  end

  def end_date
    Time.at(effective_date).gmtime
  end


  def results
    Result.where("value.test_id"=> self.id).order_by(["value.last" , :asc])
  end

  def measure_results(measure)
      self.results.where({"value.hqmf_id" => measure.hqmf_id, })
  end



  def destroy
    self.results.destroy
    self.records.destroy
    Mongoid.default_session["query_cache"].where({"test_id" => self.id}).remove_all
    super
  end

  def delete
     self.results.destroy
     self.records.destroy
     Mongoid.default_session["query_cache"].where({"test_id" => self.id}).remove_all
    super
  end


  def self.match_calculation_results(expected_result,reported_result)

    validation_errors = []
    _ids = expected_result["population_ids"].dup
    if reported_result.nil? || reported_result.keys.length <=1
      message = "Could not find entry for measure #{expected_result["measure_id"]} with the following population ids "
      message +=  _ids.inspect
      validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: expected_result["measure_id"] , stratification: _ids['stratification'], validator_type: :result_validation)
      return validation_errors
    end

    _ids = expected_result["population_ids"].dup
    # remove the stratification entry if its there, not needed to test against values
    stratification = _ids.delete("stratification")


    _ids.keys.each do |pop_key|


      if !expected_result[pop_key].nil?

        # only add the error that they dont match if there was an actual result
        if !reported_result.empty? && !reported_result.has_key?(pop_key)
          message = "Could not find value"
          message += " for stratification #{stratification} " if stratification
          message += " for Population #{pop_key}"
          validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
        elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
         err = "expected #{pop_key} #{_ids[pop_key]} value #{expected_result[pop_key]} does not match reported value #{reported_result[pop_key]}"
         validation_errors << ExecutionError.new(message: err, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
        end
           # Check supplemental data elements
        ex_sup = (expected_result["supplemental_data"] || {})[pop_key]
        reported_sup  = (reported_result[:supplemental_data] || {})[pop_key]
        if stratification.nil? && ex_sup

          sup_keys = ex_sup.keys.reject{|k| k == "" || k.nil?}
          # check to see if we expect sup data and if they provide it a short circuit the rest of the testing
          # if they do not
          if sup_keys.length>0 && reported_sup.nil?
              err = "supplemental data for #{pop_key} not found expected  #{ex_sup}"
              validation_errors << ExecutionError.new(message: err, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
          else
            # for each supplemental data item (RACE, ETHNICITY,PAYER,SEX)
            sup_keys.each do |sup_key|


              sup_value  = (ex_sup[sup_key] || {}).reject{|k,v| (k.nil? || k == "" || v.nil? || v=="" || v=="UNK")}
              reported_sup_value = reported_sup[sup_key]
              if reported_sup_value.nil?
                err = "supplemental data for #{pop_key} #{sup_key} #{sup_value} expected but was not found"
               validation_errors << ExecutionError.new(message: err, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
              else
                sup_value.each_pair do |code,value|
                  if code != "UNK" && value != reported_sup_value[code]
                   err = "expected supplemental data for #{pop_key} #{sup_key} #{code} value [#{value}] does not match reported supplemental data value [#{ reported_sup_value[code]}]"
                   validation_errors << ExecutionError.new(message: err, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
                  end
                end
              end
            end
          end
        end
      end
    end

    validation_errors
  end

end
