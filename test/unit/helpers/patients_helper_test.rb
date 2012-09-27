require 'test_helper'

class PatientsHelperTest < ActionView::TestCase

  test "patient image should return the right image" do
    p = Record.new(:gender => 'M', :birthdate => Time.now.years_ago(20),
                   :race => {'code'=>"1002-5"}, 
                   :ethnicity => {'code'=>"2186-5" })
    assert_equal '/assets/avatars/indianman.png', patient_picture(p)
    p.race = nil
    assert_equal '/assets/avatars/unknown.png', patient_picture(p)

    p = Record.new(:gender => 'F', :birthdate => Time.now.years_ago(5),
                   :race => {'code'=> "2028-9"} ,
                   :ethnicity =>{'code'=>"2186-5" })
    assert_equal '/assets/avatars/asiangirl.png', patient_picture(p)
    p.race = nil
    assert_equal '/assets/avatars/unknown.png', patient_picture(p)

    p = Record.new(:gender => 'M', :birthdate => Time.now.years_ago(5),
                   :race => {'code'=> "2054-5"} ,
                   :ethnicity =>{'code'=>"2186-5" })
    assert_equal '/assets/avatars/blackboy.png', patient_picture(p)
    p.race = nil
    assert_equal '/assets/avatars/unknown.png', patient_picture(p)

     p = Record.new(:gender => 'F', :birthdate => Time.now.years_ago(20),
                   :race => {'code'=> "2076-8"} ,
                   :ethnicity =>{'code'=>"2186-5" })
    assert_equal '/assets/avatars/hawaiianwoman.png', patient_picture(p)
    p.race = nil
    assert_equal '/assets/avatars/unknown.png', patient_picture(p)
  end

  test "should convert result to markup" do
    assert result_to_markup(true)  == '<img src="/assets/pass.png"/>'
    assert result_to_markup(false) == ''
  end

end
