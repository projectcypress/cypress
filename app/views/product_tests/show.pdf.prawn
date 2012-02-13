pdf.text "Test Results Produced by Project Cypress - projectcypress.org\n\n"
pdf.text  "Candidate EHR: #{@vendor.name}" 
pdf.text "EHR POC: #{@vendor.poc}"
pdf.text "E-mail: #{@vendor.email}"
pdf.text "Phone: #{@vendor.tel}\n\n"

pdf.text "Proctor: #{@vendor.proctor}"
pdf.text "E-mail: #{@vendor.proctor_email}"
pdf.text "Phone: #{@vendor.proctor_tel}\n\n"

pdf.text "Product: #{@product.name}"
pdf.text "Test: #{@test.name}"
pdf.text "Run at: #{@current_execution.pretty_date}\n\n"

if @current_execution.validation_errors
  pdf.text "PQRI Validation Errors:\n\n"
  @current_execution.validation_errors.each do |error|  
    pdf.text error + "\n\n"
  end
end

data = []
pdf.text "Failing Measures:"  
if @current_execution.failing_measures.size > 0
  data << ["Failing","Denominator","Numerator","Exclusions"]
  
  @current_execution.failing_measures.each do |measure|
    expected_result = @current_execution.expected_result(measure)
    reported_result = @current_execution.reported_result(measure.key)
    data << ["NQF#{measure['id']}#{measure.sub_id}\n" + measure.name + " " + (measure.subtitle || "") ,"#{reported_result['denominator']}/#{expected_result['denominator']}","#{reported_result['numerator']}/#{expected_result['numerator']}","#{reported_result['exclusions']}/#{expected_result['exclusions']}"]
  end  
end

if data.size > 0 then
  pdf.table(data)
else 
  pdf.text "NONE", :align => :center
end

data=[]
pdf.text "\n\nPassing Measures:"  
if @current_execution.passing_measures.size > 0
data << ["Passing","Denominator","Numerator","Exclusions"]
  @current_execution.passing_measures.each do |measure|
    expected_result = @current_execution.expected_result(measure)
    reported_result = @current_execution.reported_result(measure.key)
    data << ["NQF#{measure['id']}#{measure.sub_id}\n" + measure.name + " " + (measure.subtitle || "") ,"#{reported_result['denominator']}/#{expected_result['denominator']}","#{reported_result['numerator']}/#{expected_result['numerator']}","#{reported_result['exclusions']}/#{expected_result['exclusions']}"]
  end
end

if data.size > 0 then
  pdf.table(data)
else 
  pdf.text "NONE", :align => :center
end
