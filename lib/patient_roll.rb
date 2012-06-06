
module Cypress
  class PatientRoll
  
      def self.roll(*args)
	    if args.size == 1 or args.size ==3
		    if args.size == 1
			    effective_date = Time.gm(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"]).to_i
			    start_date =  Date.strptime args[0] , '%m/%d/%Y'
		        start_time = Time.utc(start_date.year, start_date.month, start_date.day).to_i
		        d = (start_time-effective_date)/86400
	            effective_date = APP_CONFIG["effective_date"]
		        APP_CONFIG["effective_date"]["year"] = start_date.year
				APP_CONFIG["effective_date"]["year"] = start_date.month
				APP_CONFIG["effective_date"]["year"] = start_date.day
				binding.pry
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
			                v[i] = Time.at(n).advance(:years => y, :months => m, :days => d).to_i
					    else
					        v[i]["date"] = Time.at(v[i]["date"]).advance(:years => y, :months => m, :days => d).to_i
					    end
				    end
				    ms[k] = v
		        end
		    end
	        patient.birthdate = Time.at(patient.birthdate).advance(:years => y, :months => m, :days => d)
		    patient_attributes = [patient.allergies, patient.care_goals,  patient.laboratory_tests, patient.encounters, patient.conditions, patient.procedures, patient.medications,  patient.social_history, patient.immunizations, patient.medical_equipment]	
		    patient_attributes.each do |a|
		        a.each do |v|
				    if v.time != nil
			            v.time = Time.at(v.time).advance(:years => y, :months => m, :days => d)
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