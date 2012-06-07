
module Cypress
  class PatientRoll
  
      def self.roll(*args)
	    if args.size == 1 or args.size ==3
		    if args.size == 1
			    effective_date = Date.new(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"])
			    start_date =  Date.strptime args[0] , '%m/%d/%Y'
				y = start_date.year - effective_date.year
				m = start_date.month - effective_date.month
				d = start_date.day - effective_date.day
		    else
		        y = args[0].to_i
	            m = args[1].to_i
	            d = args[2].to_i
		    end
	    Record.where('test_id' => nil).all.entries.each do |patient|
		    patient.measures.each do |ms|
			    ms= ms[1] 
			    ms.each_pair do |k,v|
			        v.each_with_index do |n, i|
					    if v[i].kind_of?  Bignum or v[i].kind_of?  Fixnum
						    v[i] = Time.at(v[i]).advance(:days => d).to_i
							v[i] = Time.at(v[i]).advance(:months => m).to_i
							v[i] = Time.at(v[i]).advance(:years => y).to_i
					    else
					        v[i]["date"] = Time.at(v[i]["date"]).advance(:days => d).to_i
							v[i]["date"] = Time.at(v[i]["date"]).advance(:months => m).to_i
							v[i]["date"] = Time.at(v[i]["date"]).advance(:years => y).to_i
					    end
				    end
				    ms[k] = v
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
		        a.each do |v|
				    if v.time != nil
			            v.time = Time.at(v.time).advance(:days => d).to_i
						v.time = Time.at(v.time).advance(:months => m).to_i
						v.time = Time.at(v.time).advance(:years => y).to_i
				    end
	            end
		    end
		patient.save
	 end
	 puts "Date rolled Successfully"
		end   
      end
   end
  end