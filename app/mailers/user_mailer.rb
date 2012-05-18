class UserMailer < ActionMailer::Base
  default from: "cypress-dev-list@lists.mitre.org"
  
  # Send all of the Records for a given ProductTest in a particular file format
  def send_records(test, format)
    @test = test
    @product = @test.product
    @vendor = @product.vendor
    
    # Define our filename. All formats are .zip except for CSV
    filename = "patient_records"
    if format == 'csv'
      filename += ".csv"
    else
      filename += "_#{format}.zip"
    end
    
    # Include the attachment and fire off the message
    records_file = @test.generate_records_file(format)
    attachments[filename] = records_file.read
    mail(:to => @vendor.email, :subject => "Cypress test patients for #{@test.name}", :reply_to => @test.proctor_email)
    
    # The records_file will clean up eventually, but let's do it now
    records_file.close
    records_file.unlink
  end
end