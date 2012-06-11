require 'test_helper'
require 'patient_roll'

class PatientRollTest< ActiveSupport::TestCase
  setup do
    collection_fixtures('records','_id','test_id')
  end

  test "should roll dates forward by years, months, days" do
	  rosa_control = [Record.where(:first => 'Rosa').first.birthdate, 
  	                Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
  			            Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
      			        Record.where(:first => 'Rosa').first.care_goals.first.time,
      			        Record.where(:first => 'Rosa').first.vital_signs.first.time,
      			        Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
      			        Record.where(:first => 'Rosa').first.encounters.second.time,
      			        Record.where(:first => 'Rosa').first.conditions.first.time,
      			        Record.where(:first => 'Rosa').first.procedures.second.time,
      			        Record.where(:first => 'Rosa').first.medications.second.time,
      			        Record.where(:first => 'Rosa').first.immunizations.second.time]

  	selena_control = Record.where(:first => 'Selena').first.birthdate		
    rachel_control = Record.where(:first => 'Rachel').first.birthdate	

  	rosa_control.each_with_index do |time, index|
  	  rosa_control[index] = Time.at(time).advance(:years => -132, :months => 5, :days => 27).to_i
  	end
  	selena_control = Time.at(selena_control).advance(:years => -132, :months => 5, :days => 27).to_i

    Cypress::PatientRoll.rollYearMonthDay(-132,5,27)

  	rosa_variable = [Record.where(:first => 'Rosa').first.birthdate, 
  	                 Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
  			             Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
       			         Record.where(:first => 'Rosa').first.care_goals.first.time,
       			         Record.where(:first => 'Rosa').first.vital_signs.first.time,
       			         Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
       			         Record.where(:first => 'Rosa').first.encounters.second.time,
       			         Record.where(:first => 'Rosa').first.conditions.first.time,
       			         Record.where(:first => 'Rosa').first.procedures.second.time,
       			         Record.where(:first => 'Rosa').first.medications.second.time,
       			         Record.where(:first => 'Rosa').first.immunizations.second.time]

    selena_variable = Record.where(:first => 'Selena').first.birthdate		
  	rachel_variable = Record.where(:first => 'Rachel').first.birthdate

    assert_equal rosa_control, rosa_variable
  	assert_equal selena_control, selena_variable 
  	assert_equal rachel_control, rachel_variable 
  end
 
  test "should roll date forward by time from effective date" do
    effective_date = Time.gm(APP_CONFIG["effective_date"]["year"],
                             APP_CONFIG["effective_date"]["month"],
                             APP_CONFIG["effective_date"]["day"]) 
    effective_date = effective_date.advance(:years => 20, :months => -2, :days => 13)

    rosa_control = [Record.where(:first => 'Rosa').first.birthdate, 
	                  Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
  			            Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
      			        Record.where(:first => 'Rosa').first.care_goals.first.time,
      			        Record.where(:first => 'Rosa').first.vital_signs.first.time,
      			        Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
      			        Record.where(:first => 'Rosa').first.encounters.first.time,
      			        Record.where(:first => 'Rosa').first.conditions.first.time,
      			        Record.where(:first => 'Rosa').first.procedures.second.time,
      			        Record.where(:first => 'Rosa').first.medications.second.time,
      			        Record.where(:first => 'Rosa').first.immunizations.second.time]
					
	  selena_control = Record.where(:first => 'Selena').first.birthdate		
	  rachel_control = Record.where(:first => 'Rachel').first.birthdate	
	
	  rosa_control.each_with_index do |time, index|
	    rosa_control[index] = Time.at(time).to_date.advance(:years => 20, :months => -2, :days => 13).to_time.to_i
	  end
	  selena_control = Time.at(selena_control).advance(:years => 20, :months => -2, :days => 13).to_i
	
    Cypress::PatientRoll.rollEffectiveDate(effective_date.strftime("%m/%d/%Y"))
	
	  rosa_variable = [Record.where(:first => 'Rosa').first.birthdate, 
	                   Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
			               Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
      			         Record.where(:first => 'Rosa').first.care_goals.first.time,
      			         Record.where(:first => 'Rosa').first.vital_signs.first.time,
      			         Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
      			         Record.where(:first => 'Rosa').first.encounters.first.time,
      			         Record.where(:first => 'Rosa').first.conditions.first.time,
      			         Record.where(:first => 'Rosa').first.procedures.second.time,
      			         Record.where(:first => 'Rosa').first.medications.second.time,
      			         Record.where(:first => 'Rosa').first.immunizations.second.time]
		
		puts Time.at(rosa_control[6]).to_date
		puts Time.at(rosa_variable[6]).to_date
    
    selena_variable = Record.where(:first => 'Selena').first.birthdate		
	  rachel_variable = Record.where(:first => 'Rachel').first.birthdate
	
    assert_equal rosa_control, rosa_variable
	  assert_equal selena_control, selena_variable 
	  assert_equal rachel_control, rachel_variable 
  end
end