When(/^the default bundle has been deprecated$/) do
  active_bundle = Bundle.default
  inactive_bundle = FactoryBot.create(:bundle)

  inactive_bundle.update_attributes(active: true)
  active_bundle.update_attributes(active: false)
  active_bundle.deprecate
end
