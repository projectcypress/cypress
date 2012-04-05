require 'test_helper'

class PatientsHelperTest < ActionView::TestCase
  
  test "patient image should return the right image" do

    flunk "Fix this when records are using ethnicity codes"
    p = Record.new(:gender => 'M', :birthdate => Time.now.years_ago(20),
                   :race => {'code'=>"1002-5"}, 
                   :ethnicity => {'code'=>"2186-5" })
    img = patient_picture(p)
    assert_equal '/assets/avatars/indianman.png', img
    
    p = Record.new(:gender => 'F', :birthdate => Time.now.years_ago(5),
                   :race => {'code'=> "2028-9"} ,
                   :ethnicity =>{'code'=>"2186-5" })
    img = patient_picture(p)
    assert_equal '/assets/avatars/asiangirl.png', img
  end
end
