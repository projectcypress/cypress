require 'validators/smoking_gun_validator'
require 'validators/qrda_cat1_validator'

class QRDAProductTest < ProductTest
  include Mongoid::Attributes::Dynamic
  include ::Validators


  belongs_to :calculated_product_test, foreign_key: "calculated_test_id", index: true

  def validators
    @validators ||= [QrdaCat1Validator.new(self.bundle, self.measures, self.parent_measures),
    SmokingGunValidator.new(self.measures, self.records, self.id),
    MeasurePeriodValidator.new()]
  end

  def execute(file)
    te = self.test_executions.build(expected_results: self.expected_results,
           execution_date: Time.now.to_i)
    te.artifact = Artifact.new(file: file)
    te.save
    te.validate_artifact(validators)
    te.save
    te
  end

  def measures
    return [] if !measure_ids
    self.bundle.measures.in(:hqmf_id => measure_ids).top_level.order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end

  def parent_measures
    return [] if !measure_ids
    self.bundle.measures.in(:hqmf_id => parent_cat3_ids).top_level.order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end

  def self.product_type_measures(bundle)
    bundle.measures.top_level
  end


end
