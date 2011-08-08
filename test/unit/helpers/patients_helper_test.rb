require 'test_helper'

class PatientsHelperTest < ActionView::TestCase
  test "patient image should return the right image" do
    p = Record.new(:gender => 'M', :birthdate => Time.now.years_ago(20))
    img = patient_picture(p)
    assert_equal '/images/dad.jpg', img
    
    p = Record.new(:gender => 'F', :birthdate => Time.now.years_ago(5))
    img = patient_picture(p)
    assert_equal '/images/girl.jpg', img
  end
end
