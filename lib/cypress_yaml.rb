module CypressYaml
  def sub_yml_setting(key, val)
    yml_text = File.read("#{Rails.root}/config/cypress.yml")
    sub_string = /#{key}:(.*?)\n/
    if val.is_a? String
      yml_text.sub!(sub_string, "#{key}: \"#{val}\"\n")
    elsif val.is_a? Symbol
      yml_text.sub!(sub_string, "#{key}: :#{val}\n")
    else
      yml_text.sub!(sub_string, "#{key}: #{val}\n")
    end
    File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts yml_text }
  end
end
