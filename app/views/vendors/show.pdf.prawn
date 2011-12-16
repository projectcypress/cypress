pdf.text "Test Results Produced by Project Cypress - projectcypress.org\n\n"
pdf.text  "Candidate EHR: #{@vendor.name}" 
pdf.text "EHR POC: #{@vendor.poc}"
pdf.text "E-mail: #{@vendor.email}"      
pdf.text "Phone: #{@vendor.tel}\n\n"             

pdf.text "Proctor: #{@vendor.proctor}"  
pdf.text "E-mail: #{@vendor.proctor_email}"  
pdf.text "Phone: #{@vendor.proctor_tel}\n\n"      

if @vendor.notes
         @vendor.notes.each do |note|
            pdf.text "#{note.time.strftime('%Y-%m-%d')} - #{note.text}" 
        end
end

if @vendor.validation_errors
        pdf.text "PQRI Validation Errors:\n\n"
        @vendor.validation_errors.each do |error|  
        pdf.text error + "\n\n"
        end
      end


data = []
pdf.text "Failing Measures:"  
if @vendor.failing_measures.size > 0
  data << ["Failing","Denominator","Numerator","Exclusions"]
  
  @vendor.failing_measures.each do |measure|
    expected_result = @vendor.expected_result(measure)
    reported_result = @vendor.reported_result(measure.key)
    data << ["NQF#{measure['id']}#{measure.sub_id}\n" + measure.name + " " + (measure.subtitle || "") ,"#{reported_result['denominator']}/#{expected_result['denominator']}","#{reported_result['numerator']}/#{expected_result['numerator']}","#{reported_result['exclusions']}/#{expected_result['exclusions']}"]
  end
  
  
end
          
pdf.table(data)

data=[]
pdf.text "\n\nPassing Measures:"  
if @vendor.passing_measures.size > 0
data << ["Passing","Denominator","Numerator","Exclusions"]
  
  @vendor.passing_measures.each do |measure|
    expected_result = @vendor.expected_result(measure)
    reported_result = @vendor.reported_result(measure.key)
    data << ["NQF#{measure['id']}#{measure.sub_id}\n" + measure.name + " " + (measure.subtitle || "") ,"#{reported_result['denominator']}/#{expected_result['denominator']}","#{reported_result['numerator']}/#{expected_result['numerator']}","#{reported_result['exclusions']}/#{expected_result['exclusions']}"]
  end

end


pdf.table(data)