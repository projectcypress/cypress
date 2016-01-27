# yes this is a bit ugly as it is aliasing The bundle class but it
# works for now until we can truley unify these items accross applications
Bundle = HealthDataStandards::CQM::Bundle
class Bundle
  has_many :product_tests, :dependent => :destroy
  def results
    HealthDataStandards::CQM::PatientCache.where(bundle_id: id, 'value.test_id' => nil)
                                          .order_by(['value.last', :asc])
  end

  def delete(options = {})
    super
    results.destroy
  end
end
