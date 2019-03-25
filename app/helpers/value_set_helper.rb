module ValueSetHelper
  # TODO: Remove when loading measures directly from specifications
  def direct_reference_code_hash(code_system_name, code_system_version, code)
    'drc-' + Digest::SHA2.hexdigest("#{code_system_name} #{code['id']} #{code['name']} #{code_system_version}")
  end
end
