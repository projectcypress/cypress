module AdminHelper
  def application_mode
    return 'Internal' if mode_internal?
    return 'Demo' if mode_demo?
    return 'ATL' if mode_atl?
    'Custom'
  end

  def application_mode_settings
    settings_hash = { auto_approve: Settings[:auto_approve], ignore_roles: Settings[:ignore_roles], debug_features: Settings[:enable_debug_features] }
    settings_hash[:default_role] = if Settings[:default_role].nil?
                                     'None'
                                   elsif Settings[:default_role] == :atl
                                     'ATL'
                                   else
                                     Settings[:default_role].to_s.humanize
                                   end
    settings_hash
  end

  def mode_internal?
    Settings[:auto_approve] && Settings[:ignore_roles] && Settings[:enable_debug_features] && Settings[:default_role].nil?
  end

  def mode_demo?
    Settings[:auto_approve] && !Settings[:ignore_roles] && Settings[:enable_debug_features] && Settings[:default_role] == :user
  end

  def mode_atl?
    !Settings[:auto_approve] && !Settings[:ignore_roles] && !Settings[:enable_debug_features] && Settings[:default_role].nil?
  end

  def mode_internal
    Settings[:auto_approve] = true
    Settings[:ignore_roles] = true
    Settings[:default_role] = nil
    Settings[:enable_debug_features] = true
  end

  def mode_demo
    Settings[:auto_approve] = true
    Settings[:ignore_roles] = false
    Settings[:default_role] = :user
    Settings[:enable_debug_features] = true
  end

  def mode_atl
    Settings[:auto_approve] = false
    Settings[:ignore_roles] = false
    Settings[:default_role] = nil
    Settings[:enable_debug_features] = false
  end

  def mode_custom(settings)
    Settings[:auto_approve] = settings['auto_approve'] == 'enable'
    Settings[:ignore_roles] = settings['ignore_roles'] == 'enable'
    Settings[:default_role] = settings['default_role'] == 'None' ? nil : settings['default_role'].underscore.to_sym
    Settings[:enable_debug_features] = settings['debug_features'] == 'enable'
  end
end
