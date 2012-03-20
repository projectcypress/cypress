module PatientsHelper
  
  
  def race(patient)
     r = Race.from_code(patient.race["code"]).first if patient.race
     r = r || {}
     r["name"] || ""
     patient.race  #until the race comes in as a code
  end
  
  def ethnicity(patient)
    e = Ethnicity.from_code(patient.ethnicity["code"]).first if patient.ethnicity
    e = e || {}
    e["name"] || ""
    patient.ethnicity #until the ethnicity comes in as a code
  end
  
  def result_to_markup(included)
    if included
      '<img src="/assets/pass.png"/>'
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
  
  def patient_picture(patient)
    image_name = '/assets/avatars/'
   
    case race(patient).downcase
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
    if ethnicity(patient).downcase == 'hispanic or latino'
      image_name += 'hispanic'
    end

    # if any of the info is unknown, use the catch-all image
    if image_name.include? 'unknown'
      image_name = '/assets/avatars/unknown'
    end

    image_name += '.png'
  end

end
