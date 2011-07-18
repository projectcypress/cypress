module PatientsHelper
  def result_to_markup(included)
    if included
      '<img src="/images/pass.png"/>'
    else
      ''
    end
  end
  
  def result_to_class(included)
    if included
      'class="p"'
    else
      ''
    end
  end
  
  def code_display(entry)
    if entry.single_code_value?
      code = entry.codes.first[1].first
      code_system_oid = QME::Importer::CodeSystemHelper.oid_for_code_system(entry.codes.first[0])
      "<code code=\"#{code}\" codeSystem=\"#{code_system_oid}\"/>"
    else
      all_codes = []
      entry.codes.each_pair {|key, values| values.each {|v| all_codes << {:set => key, :value => v}}}
      first_code = all_codes.first
      code_string = "<code code=\"#{first_code[:value]}\" codeSystem=\"#{QME::Importer::CodeSystemHelper.oid_for_code_system(first_code[:set])}\">\n"
      all_codes[1..-1].each do |cv|
        code_string += "<translation code=\"#{cv[:value]}\" codeSystem=\"#{QME::Importer::CodeSystemHelper.oid_for_code_system(cv[:set])}\"/>\n"
      end
      code_string += "</code>"
      code_string
    end
  end

end
