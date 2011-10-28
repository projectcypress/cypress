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
    case entry.status.to_s
    when 'active'
      '55561003'
    when 'inactive'
      '73425007'
    when 'resolved'
      '413322009'
    end
  end
  
  def patient_picture(patient)
    image_name = '/images/avatars/'

    case patient.race.downcase
      when 'american indian or alaska native'
        image_name += 'indian'
      when 'asian'
        image_name += 'asian'
      when 'black or african american'
        image_name += 'black'
      when 'native hawaiian or other pacific islander'
        image_name += 'hawaiian'
      when 'other race'
        image_name += 'other'
      when 'white'
        image_name += 'white'
      else
        image_name += 'unknown'
      end

    # factor in the age for males
    if patient.gender == 'M'
      if patient.over_18?
        image_name += 'man'
      else
        image_name += 'boy'
      end
    # and females
    else
      if patient.over_18?
        image_name += 'woman'
      else
        image_name += 'girl'
      end
    end

    # consider ethnicity (only Hispanic or not, currently)
    if patient.ethnicity.downcase == 'hispanic or latino'
      image_name += 'hispanic'
    end

    # if any of the info is unknown, use the catch-all image
    if image_name.include? 'unknown'
      image_name = '/images/avatars/unknown'
    end

    image_name += '.png'
  end

end
