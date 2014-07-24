# yes this is a bit ugly as it is aliasing The bundle class but it
# works for now until we can truley unify these items accross applications
Bundle = HealthDataStandards::CQM::Bundle
class Bundle
  field :smoking_gun_capable, type: Boolean
  has_many :product_tests
  has_many :measures

  store_in collection: 'bundles'
  def results
    Result.where(bundle_id: self.id, "value.test_id" => nil).order_by(["value.last",:asc])
  end

  def delete
    self.measures.destroy
    self.records.destroy
    self.value_sets.destroy
    self.results.destroy
    product_tests.destroy
    super
  end

end
