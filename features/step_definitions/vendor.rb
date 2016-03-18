# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

Given(/^the user has created a vendor$/) do
  @vendor = FactoryGirl.create(:vendor)
end

Given(/^the user is on the create vendor page$/) do
  visit new_vendor_path
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user visits the home page$/) do
  visit '/'
end

When(/^the user visits the create vendor page$/) do
  visit '/'
  page.click_button 'Add Vendor'
end

When(/^the user creates a vendor with appropriate information$/) do
  @vendor = FactoryGirl.build(:vendor)
  steps %( When the user creates a vendor with a name of #{@vendor.name} )
end

When(/^the user creates a vendor with no name$/) do
  @vendor = FactoryGirl.build(:vendor_no_name)
  page.fill_in 'Vendor Name', with: @vendor.name
end

When(/^the user creates two vendors with the same name$/) do
  @vendor = FactoryGirl.build(:vendor_static_name)
  steps %(
    When the user creates a vendor with a name of #{@vendor.name}
    When the user creates a vendor with a name of #{@vendor.name}
  )
end

When(/^the user creates a vendor with a name of (.*)$/) do |name|
  steps %( When the user visits the create vendor page )
  page.fill_in 'Vendor Name', with: name
  page.click_button 'Create Vendor'
end

When(/^the user cancels creating a vendor$/) do
  @vendor = FactoryGirl.build(:vendor)
  steps %( When the user visits the create vendor page )
  page.click_button 'Cancel'
end

When(/^the user edits the vendor$/) do
  visit '/'
  page.click_button 'Edit Vendor'
  page.fill_in 'URL', with: 'www.example.com'
  page.click_button 'Submit Changes'
end

When(/^the user removes the vendor$/) do
  visit '/'
  page.click_button 'Edit Vendor'
  page.click_button 'Delete Vendor'
  page.fill_in 'Remove Name', with: @vendor.name
  page.click_button 'Remove'
end

When(/^the user cancels removing a vendor$/) do
  visit '/'
  page.click_button 'Edit Vendor'
  page.click_button 'Delete Vendor'
  page.find('div.modal-footer').find('button', text: 'Cancel').click
  page.click_button 'Cancel', visible: true
end

When(/^the user views the vendor information$/) do
  visit '/'
  page.click_link @vendor.name
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see a notification saying the vendor was created$/) do
  page.assert_text 'was created'
end

Then(/^the user should not be able to create a vendor$/) do
  assert_equal true, page.has_button?('Create Vendor', disabled: true)
end

Then(/^the user should see an error message saying the vendor name has been taken$/) do
  page.assert_text 'was already taken'
end

Then(/^the user should not see the vendor$/) do
  page.assert_no_text @vendor.name
end

Then(/^the user should see a notification saying the vendor has been edited$/) do
  page.assert_text 'was edited'
end

Then(/^the user should see a notification saying the vendor has been removed$/) do
  page.assert_text 'was removed'
end

Then(/^the user should still see the vendor$/) do
  page.assert_text @vendor.name
end

Then(/^the user should see the vendor name$/) do
  page.assert_text @vendor.name
end
