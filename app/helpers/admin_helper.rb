module AdminHelper
  def application_mode
    return 'Internal' if mode_internal?
    return 'Demo' if mode_demo?
    return 'ATL' if mode_atl?
    'Custom'
  end

  def application_mode_settings
    settings_hash = { auto_approve: Settings[:auto_approve], ignore_roles: Settings[:ignore_roles] }
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
    !Settings[:auto_approve] && Settings[:ignore_roles] && Settings[:default_role].nil?
  end

  def mode_demo?
    !Settings[:auto_approve] && !Settings[:ignore_roles] && Settings[:default_role] == :user
  end

  def mode_atl?
    Settings[:auto_approve] && !Settings[:ignore_roles] && Settings[:default_role].nil?
  end
end
