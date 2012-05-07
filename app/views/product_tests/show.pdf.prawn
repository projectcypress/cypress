pdf.text "Test Results Produced by Project Cypress - projectcypress.org\n\n"
pdf.text "Candidate EHR: #{@vendor.name}" 
pdf.text "Vendor ID: #{@vendor.vendor_id}" 
pdf.text "EHR POC: #{@vendor.poc}"
pdf.text "E-mail: #{@vendor.email}"
pdf.text "Phone: #{@vendor.tel}\n\n"

pdf.text "Proctor: #{@vendor.proctor}"
pdf.text "E-mail: #{@vendor.proctor_email}"
pdf.text "Phone: #{@vendor.proctor_tel}\n\n"

pdf.text "Product: #{@product.name}"
pdf.text "Product Version: #{@product.version}"

if @current_execution.required_modules
  (n,v) = @current_execution.required_modules.first
  @current_execution.required_modules.delete(n)
  modules="Modules: #{n}: v#{v}"
  @current_execution.required_modules.each do |name,version|
    modules =  modules +", "+ name + ": v" + version
  end
  pdf.text " #{modules}"
else
  pdf.text "Modules:"
end

pdf.text "Test: #{@test.name}"
pdf.text "Run at: #{@current_execution.pretty_date}\n\n"

if @test.notes
  pdf.text "Notes:"
  @test.notes.each do |note|
    pdf.text "#{note.time.strftime('%m/%d/%Y')}: #{note.text}\n"
  end
  pdf.text "\n"
end

data = []
pdf.text "Failing Measures:"  
if @current_execution.failing_measures.size > 0
  data << ["Failing","Denominator","Numerator","Exclusions"]
  
  @current_execution.failing_measures.each do |measure|
    expected_result = @current_execution.expected_result(measure)
    reported_result = @current_execution.reported_result(measure.key)
    data << ["#{measure.key}\n" + measure.name + " " + (measure.subtitle || "") ,"#{reported_result['denominator']}/#{expected_result['denominator']}","#{reported_result['numerator']}/#{expected_result['numerator']}","#{reported_result['exclusions']}/#{expected_result['exclusions']}"]
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
    data << ["#{measure.key}\n" + measure.name + " " + (measure.subtitle || "") ,"#{reported_result['denominator']}/#{expected_result['denominator']}","#{reported_result['numerator']}/#{expected_result['numerator']}","#{reported_result['exclusions']}/#{expected_result['exclusions']}"]
  end
end

if data.size > 0 then
  pdf.table(data)
else 
  pdf.text "NONE", :align => :center
end

if @current_execution.validation_errors
  pdf.text "PQRI Validation Errors:\n\n"
  @current_execution.validation_errors.each do |error|  
    pdf.text error + "\n\n"
  end
end
