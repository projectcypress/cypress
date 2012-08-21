FactoryGirl.define do
  
  factory :ehr1 do
    
    products   {[Factory.build(:product)]}
    name    "Test EHR Vendor 1"
    vendor_id    "1"
    url    "www.example.com"
    address    ""
    state    "MA"
    zip    "02144"
    poc    "John Mazella"
    email    "john@texample.com"
    tel    "555-555-5555"
    fax    "555-555-5555"
    proctor    "Fred Bloggs"
    proctor_email    "fred@example.com"
    proctor_tel    "555-555-5555"
    accounts_poc    "Bill Smith"
    accounts_email    "bill@example.com"
    accounts_tel    "555-555-5555"
    tech_poc    "Ted Mcginley"
    tech_email    "ted@example.com"
    tech_tel    "555-555-5555"
    press_poc    "Gary Oldman"
    press_email    "gary@example.com"
    press_tel    "555-555-5555"
  end
  
  
  factory :ehr2 do

  	name  "Test EHR Vendor 2"
  	vendor_id  "2"
  	url  "www.example.com"
  	address  ""
  	state  "MA"
  	zip  "02144"
  	poc  "John Mazella"
  	email  "john@texample.com"
  	tel  "555-555-5555"
  	fax  "555-555-5555"
  	accounts_poc  "Bill Smith"
  	accounts_email  "bill@example.com"
  	accounts_tel  "555-555-5555"
  	tech_poc  "Ted Mcginley"
  	tech_email  "ted@example.com"
  	tech_tel  "555-555-5555"
  	press_poc  "Gary Oldman"
  	press_email  "gary@example.com"
  	press_tel  "555-555-5555"
   end
  
end