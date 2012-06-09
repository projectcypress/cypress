require 'test_helper'
require 'patient_roll'

class PatientRollTest< ActiveSupport::TestCase

	setup do
    collection_fixtures('records','_id','test_id')
  	@roll = Cypress::PatientRoll
  end

  test "should roll dates forward by years, months, days" do
	  control = [Record.where(:first => 'Rosa').first.birthdate, 
              Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
  			      Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
  			      Record.where(:first => 'Rosa').first.care_goals.first.time,
  			      Record.where(:first => 'Selena').first.vital_signs.first.time,
  			      Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
  			      Record.where(:first => 'Selena').first.encounters.second.time,
  			      Record.where(:first => 'Selena').first.conditions.first.time,
  			      Record.where(:first => 'Rosa').first.procedures.second.time,
  			      Record.where(:first => 'Selena').first.medications.second.time,
  			      Record.where(:first => 'Rosa').first.immunizations.second.time]

  	control.each_with_index do |t, i|
	    control[i] = Time.at(t).advance(:years => -132, :months => 5, :days => 27).to_i
  	end
    @roll.roll(-132,5,27)

  	variable = [Record.where(:first => 'Rosa').first.birthdate, 
  	           Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
  			       Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
  			       Record.where(:first => 'Rosa').first.care_goals.first.time,
  			       Record.where(:first => 'Selena').first.vital_signs.first.time,
  			       Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
  			       Record.where(:first => 'Selena').first.encounters.second.time,
  			       Record.where(:first => 'Selena').first.conditions.first.time,
  			       Record.where(:first => 'Rosa').first.procedures.second.time,
  			       Record.where(:first => 'Selena').first.medications.second.time,
  			       Record.where(:first => 'Rosa').first.immunizations.second.time]

    assert_equal control, variable
  end
 
  test "should roll date forward by time from effective date" do
    effective_date = Time.gm(APP_CONFIG["effective_date"]["year"],
                             APP_CONFIG["effective_date"]["month"],
                             APP_CONFIG["effective_date"]["day"])
    effective_date = effective_date.advance(:years => 20, :months => -2, :days => 14)

    control = [Record.where(:first => 'Rosa').first.birthdate, 
	            Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
			        Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
			        Record.where(:first => 'Rosa').first.care_goals.first.time,
			        Record.where(:first => 'Selena').first.vital_signs.first.time,
			        Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
			        Record.where(:first => 'Selena').first.encounters.second.time,
			        Record.where(:first => 'Selena').first.conditions.first.time,
			        Record.where(:first => 'Rosa').first.procedures.second.time,
			        Record.where(:first => 'Selena').first.medications.second.time,
			        Record.where(:first => 'Rosa').first.immunizations.second.time]
	  control.each_with_index do |t, i|
	    control[i] = Time.at(t).to_date.advance(:years => 20, :months => -2, :days => 14).to_time.to_i
	  end
	
    @roll.roll(effective_date.strftime("%m/%d/%Y"))
	
	  variable = [Record.where(:first => 'Rosa').first.birthdate, 
	              Record.where(:first => 'Rosa').first.measures["0002"].first.second.first,
			          Record.where(:first => 'Rosa').first.measures["0073"]["diastolic_blood_pressure_physical_exam_finding"].second["date"],
			          Record.where(:first => 'Rosa').first.care_goals.first.time,
			          Record.where(:first => 'Selena').first.vital_signs.first.time,
			          Record.where(:first => 'Rosa').first.laboratory_tests.second.time,
			          Record.where(:first => 'Selena').first.encounters.second.time,
			          Record.where(:first => 'Selena').first.conditions.first.time,
			          Record.where(:first => 'Rosa').first.procedures.second.time,
			          Record.where(:first => 'Selena').first.medications.second.time,
			          Record.where(:first => 'Rosa').first.immunizations.second.time]

    assert_equal control, variable
  end
end