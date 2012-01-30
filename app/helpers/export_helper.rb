module ExportHelper
  
  def export(test_id=nil, type=:csv)
     mime = (type==:csv)? "text/csv" : "application/zip"
     t = Tempfile.new("patients-#{Time.now.to_i}")
     patients = Record.where("test_id" => test_id)
     if type==:csv
       Cypress::PatientZipper.flat_file(t, patients)
     else
        Cypress::PatientZipper.zip(t, patients,type)
     end
     send_file t.path, :type =>  mime , :disposition => 'attachment', 
       :filename => 'patients_#{type.to_s}.#{(type==:csv)? "csv" : "zip"}'
     t.close
   end
   
  
end