When(/^the default bundle has been deprecated$/) do
  active_bundle = Bundle.default
  inactive_bundle = FactoryBot.create(:bundle)

  inactive_bundle.update(active: true)
  active_bundle.update(active: false)
  active_bundle.deprecate
end
