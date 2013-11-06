require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    
    collection_fixtures('users', '_id')
    collection_fixtures('records', '_id','test_id','bundle_id')
    collection_fixtures('vendors', '_id',"user_ids")
    collection_fixtures('products','_id','vendor_id', "user_id")
    collection_fixtures('product_tests', '_id','product_id',"user_id",'bundle_id')
  end
  
  test "send records forms e-mail with correct fields" do
    test = ProductTest.find("4f58f8de1d41c851eb000478")
    mail = UserMailer.send_records(test, 'html', test.product.vendor.email)

    # Several fields like from/to are arrays since there could be multiple targets. We always only have one.
    assert_equal mail.from.first, APP_CONFIG["mailer"]["from"]
    assert_equal mail.to.first, test.product.vendor.email
    assert_equal mail.subject, "Cypress test patients for #{test.name}"
    assert_match(/Cypress Team/, mail.text_part.to_s) # Doesn't need to be exact for testing
    assert_equal mail.reply_to.first, 'bobby@tables.org'
  end
  
  test "send records forms e-mail with correct attachments" do
    test = ProductTest.find("4f58f8de1d41c851eb000478")
    
    # Check that we get the appropriate attachment for every file format we might send
    formats = [ "html"]
    formats.each do |format|

      # Make sure we have any attachment at all
      mail = UserMailer.send_records(test, format, test.product.vendor.email)
      assert_equal mail.attachments.size, 1, "cannot create attachment for format #{format}"
      
      # Make sure the attachment at least has the right file type and filename
      header = mail.attachments.first.header.to_s

      assert_match(/application\/zip/, header)
      assert_match(/patient_records_#{format}\.zip/, header)

    end
  end
  
  test "mail interceptor" do
    test = ProductTest.find("4f58f8de1d41c851eb000478")
    mail = UserMailer.send_records(test, 'html', test.product.vendor.email)
    
    # In the test world, we should see our interceptor stop the outgoing mail. If this works, regular delivery should be fine in production
    assert !MailInterceptor.delivering_email(mail)
  end
end