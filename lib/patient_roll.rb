module Cypress
  class PatientRoll
    def self.roll_effective_date(dateString)
			effective_date = Date.new(APP_CONFIG["effective_date"]["year"],
                                APP_CONFIG["effective_date"]["month"],
                                APP_CONFIG["effective_date"]["day"])
			start_date =  Date.strptime dateString , '%m/%d/%Y'
			y = start_date.year - effective_date.year
			m = start_date.month - effective_date.month
			d = start_date.day - effective_date.day
			roll(y,m,d)
	  end
	  
	  def self.roll_year_month_day(y,m,d)
		  roll(y,m,d)
	  end
			
	  def self.roll(y,m,d)		
	    Record.where('test_id' => nil).all.entries.each do |patient|
		    patient.measures.each do |ms|
			    ms = ms[1] 
			    ms.each_pair do |key, factor|
		        factor.each_with_index do |time, index|
				      if factor[index].kind_of? Bignum or factor[index].kind_of? Fixnum
  						  factor[index] = Time.at(factor[index]).advance(:days => d).to_i
  							factor[index] = Time.at(factor[index]).advance(:months => m).to_i
  							factor[index] = Time.at(factor[index]).advance(:years => y).to_i
  					  else
  					    factor[index]["date"] = Time.at(factor[index]["date"]).advance(:days => d).to_i
  							factor[index]["date"] = Time.at(factor[index]["date"]).advance(:months => m).to_i
  							factor[index]["date"] = Time.at(factor[index]["date"]).advance(:years => y).to_i
  					  end
				    end
				    ms[key] = factor
		      end
		    end
	      patient.birthdate = Time.at(patient.birthdate).advance(:days => d).to_i
  			patient.birthdate = Time.at(patient.birthdate).advance(:months => m).to_i
  			patient.birthdate = Time.at(patient.birthdate).advance(:years => y).to_i
  		  patient_attributes = [patient.allergies, 
  			                      patient.care_goals, 
  								            patient.laboratory_tests, 
            								  patient.encounters, 
            								  patient.conditions, 
            								  patient.procedures,
            								  patient.medications, 
            								  patient.social_history, 
            								  patient.immunizations,
            								  patient.medical_equipment]
  		  patient_attributes.each do |a|
  		    a.each do |aspect|
  			    if aspect.time != nil
  			      aspect.time = Time.at(aspect.time).advance(:days => d).to_i
  						aspect.time = Time.at(aspect.time).advance(:months => m).to_i
  						aspect.time = Time.at(aspect.time).advance(:years => y).to_i
  				  end
  	      end
  		  end
  		  patient.save
	    end
    end
  end
end