class C3Task < Task
  
  def validators()
    @validators ||= [::Validators::QrdaCat3Validator.new(product_test.expected_results),
      ::Validators::MeasurePeriodValidator.new(),
      ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]
  end


  def execute(file)
    data = file.open.read
    doc = Nokogiri::XML(data)
    te = self.test_executions.create(expected_results:self.expected_results)
    te.artifact = Artifact.new(file: file)
    te.validate_artifact(validators, te.artifact)
    te.save
    te
  end

end