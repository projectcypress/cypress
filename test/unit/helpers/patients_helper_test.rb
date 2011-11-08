require 'test_helper'

class PatientsHelperTest < ActionView::TestCase
  test "patient image should return the right image" do
    p = Record.new(:gender => 'M', :birthdate => Time.now.years_ago(20),
                   :race => 'American Indian or Alaska Native', 
                   :ethnicity => 'Not Hispanic or Latino')
    img = patient_picture(p)
    assert_equal '/images/avatars/indianman.png', img
    
    p = Record.new(:gender => 'F', :birthdate => Time.now.years_ago(5),
                   :race => 'Asian',
                   :ethnicity => 'Not Hispanic or Latino')
    img = patient_picture(p)
    assert_equal '/images/avatars/asiangirl.png', img
  end
end
