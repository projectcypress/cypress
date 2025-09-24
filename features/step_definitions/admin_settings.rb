# frozen_string_literal: true

When(/^the user selects mode "(.*)"$/) do |mode|
  choose(mode.capitalize)
end

When(/^the user sets auto approve to "(enable|disable)"$/) do |val|
  find("#custom_options_auto_approve_#{val}").click
end

When(/^the user sets ignore roles to "(enable|disable)"$/) do |val|
  find("#custom_options_ignore_roles_#{val}").click
end

When(/^the user sets debug features to "(enable|disable)"$/) do |val|
  find("#custom_options_debug_features_#{val}").click
end

When(/^the user selects default role "(.*)"$/) do |role|
  find('#custom_options_default_role').select(role.capitalize)
end

When(/^the user submits the settings form$/) do
  click_button 'Edit Settings'
end

Then(/^the application settings in the database should be:$/) do |table|
  table.rows_hash.each do |key, expected|
    actual = case key
             when 'auto_approve'   then Settings.current.auto_approve
             when 'ignore_roles'   then Settings.current.ignore_roles
             when 'debug_features' then Settings.current.enable_debug_features
             when 'default_role'   then Settings.current.default_role.to_s
             end
    assert_equal expected.to_s, actual.to_s
  end
end
