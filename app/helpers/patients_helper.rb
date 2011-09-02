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
  
  def code_display(entry, tag_name='code', extra_content=nil)
    if entry.single_code_value?
      code = entry.codes.first[1].first
      code_system_oid = QME::Importer::CodeSystemHelper.oid_for_code_system(entry.codes.first[0])
      "<#{tag_name} code=\"#{code}\" codeSystem=\"#{code_system_oid}\" #{extra_content}><originalText>#{h entry.description}</originalText></#{tag_name}>"
    else
      all_codes = []
      entry.codes.each_pair {|key, values| values.each {|v| all_codes << {:set => key, :value => v}}}
      first_code = all_codes.first
      code_string = "<#{tag_name} code=\"#{first_code[:value]}\" codeSystem=\"#{QME::Importer::CodeSystemHelper.oid_for_code_system(first_code[:set])}\">\n"
      code_string += "<originalText>#{entry.description}</originalText>\n"
      all_codes[1..-1].each do |cv|
        code_string += "<translation code=\"#{cv[:value]}\" codeSystem=\"#{QME::Importer::CodeSystemHelper.oid_for_code_system(cv[:set])}\"/>\n"
      end
      code_string += "</#{tag_name}>"
      code_string
    end
  end
  
  def status_code_for(entry)
    case entry.status
    when :active
      '55561003'
    when :inactive
      '73425007'
    when :resolved
      '413322009'
    end
  end
  
  def patient_picture(patient)
    if patient.gender == 'M'
      if patient.over_18?
        '/images/dad.jpg'
      else
        '/images/boy.jpg'
      end
    else
      if patient.over_18?
        '/images/woman.jpg'
      else
        '/images/girl.jpg'
      end
    end
  end

end
