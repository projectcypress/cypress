require 'version'

pdf.image "#{Rails.root}/app/assets/images/cypress_logo.png", :height => 30, :width => 115, :at => [10, 725]
pdf.text_box "Test Results Produced by Project Cypress #{Cypress::Version.current} - projectcypress.org", :at => [165, 715]
stroke_color 'AAAAAA'
pdf.stroke_rounded_rectangle [0,700], 540, 85, 8
pdf.formatted_text_box [
  {:text =>"Candidate EHR:", :color => '666666', :size => 10},{ :text =>" #{@vendor.name}\n"},
  {:text =>"Vendor ID:", :color => '666666', :size => 10},{ :text =>" #{@vendor.vendor_id}\n" },
  {:text =>"EHR POC:", :color => '666666', :size => 10},{ :text =>" #{@vendor.poc}\n"},
  {:text =>"E-mail:", :color => '666666', :size => 10},{ :text =>" #{@vendor.email}\n"},
  {:text =>"Phone:", :color => '666666', :size => 10},{ :text =>" #{@vendor.tel}\n"}
], :at=> [10, 690]
pdf.text "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

pdf.stroke_rounded_rectangle [0,600], 540, 60 , 8
pdf.formatted_text_box [
  {:text =>"Proctor:", :color => '666666', :size => 10},{ :text =>" #{@test.user.first_name} #{@test.user.last_name}\n"},
  {:text =>"E-mail:", :color => '666666', :size => 10},{ :text =>" #{@test.user.email}\n" },
  {:text =>"Phone:", :color => '666666', :size => 10},{ :text =>" #{@test.user.telephone}\n"}
], :at=> [10, 590]

if @current_execution.required_modules
  (n,v) = @current_execution.required_modules.first
  @current_execution.required_modules.delete(n)
  modules="Modules: #{n}: v#{v}"
  @current_execution.required_modules.each do |name,version|
    modules =  modules +", "+ name + ": v" + version
  end
else
  modules = "Modules:"
end 

pdf.stroke_rounded_rectangle [0,525], 540, 60 , 8
pdf.formatted_text_box [
  {:text =>"Product:", :color => '666666', :size => 10},{ :text =>" #{@product.name}\n"},
  {:text => "Product Version:", :color => '666666', :size => 10},{ :text =>" #{@product.version}\n"},
  {:text => "#{modules.slice(0, modules.index(':')+1)}", :color => '666666', :size => 10},
  {:text =>" #{modules.slice(modules.index(':') + 2, modules.length)}"},
], :at=> [10, 515]

pdf.stroke_rounded_rectangle [0,450], 540, 45 , 8
pdf.formatted_text_box [
  {:text =>"Test:", :color => '666666', :size => 10},{ :text =>" #{@test.name}\n"},
  {:text =>"Run at:", :color => '666666', :size => 10},{ :text =>" ##{@current_execution.pretty_date}\n" }
], :at=> [10, 440]

if @test.notes
  pdf.text "Notes:"
  @test.notes.each do |note|
    pdf.text "#{note.time.strftime('%m/%d/%Y')}: #{note.text}\n"
  end
  pdf.text "\n"
end

pdf.stroke_horizontal_rule
pdf.text "\n"
data = [] 

pdf.text "<color rgb='FF0000' >Failing</color> Measures:", :inline_format => true
if @current_execution.failing_measures.size > 0
  data << [{:content =>"<color rgb='666666'>Measure</color>", :inline_format => true},
           {:content =>"<color rgb='666666'> Denominator</color>", :inline_format => true, :align => :center},
		       {:content =>"<color rgb='666666'> Numerator</color>", :inline_format => true, :align => :center},
		       {:content =>"<color rgb='666666'>Exclusions</color>", :inline_format => true, :align => :center}
		      ]

  @current_execution.failing_measures.each do |measure|
    expected_result = @current_execution.expected_result(measure)
    reported_result = @current_execution.reported_result(measure.key)
	  text_colors = [0,0,0,0]
	
	  reported_result.each_with_index do |val,index|
  	  if reported_result[val[0]] == expected_result[val[0]]
  	      text_colors[index] = "000000"
  	  else
  	      text_colors[index] = "FF0000"
  	  end
  	end
	
    data << [{:content=> "<color rgb='FF0000'>#{measure.key}</color>\n<color rgb='000000'>" + measure.name + " " + (measure.subtitle || "") + "</color>", :inline_format => true, :width => 300},
	          {:content=> "<color rgb='#{text_colors[0]}'>#{reported_result['denominator']}</color><color rgb='000000'>/</color><color rgb='AAAAAA'>#{expected_result['denominator']}</color>", :inline_format =>true, :align => :center},
			      {:content=> "<color rgb='#{text_colors[1]}'>#{reported_result['numerator']}</color><color rgb='000000'>/</color><color rgb='AAAAAA'>#{expected_result['numerator']}</color>", :inline_format =>true, :align => :center},
			      {:content=> "<color rgb='#{text_colors[2]}'>#{reported_result['exclusions']}</color><color rgb='000000'>/</color><color rgb='AAAAAA'>#{expected_result['exclusions']}</color>", :inline_format =>true, :align => :center}]
	end
end

if data.size > 0 then
  fill_color "ff0000"
  pdf.table(data,:cell_style =>{ :border_color => "FFFFFF" })
else 
  fill_color "000000"
  pdf.text "NONE", :align => :center
end

pdf.text "\n"
pdf.stroke_horizontal_rule
fill_color "000000"
data = []

pdf.text "\n<color rgb='539309'>Passing</color> Measures:", :inline_format => true
if @current_execution.passing_measures.size > 0
  data << [{:content =>"<color rgb='666666'>Measure</color>", :inline_format => true},
           {:content =>"<color rgb='666666'> Denominator</color>", :inline_format => true, :align => :center},
		       {:content =>"<color rgb='666666'> Numerator</color>", :inline_format => true, :align => :center},
		       {:content =>"<color rgb='666666'>Exclusions</color>", :inline_format => true, :align => :center}]
		   
  @current_execution.passing_measures.each do |measure|
    expected_result = @current_execution.expected_result(measure)
    reported_result = @current_execution.reported_result(measure.key)
	
    data << [{:content=> "<color rgb='539309'>#{measure.key}</color>\n<color rgb='000000'>" + measure.name + " " + (measure.subtitle || "") + "</color>", :inline_format => true, :width => 300},
	         {:content=> "<color rgb='000000'>#{reported_result['denominator']}/</color><color rgb='AAAAAA'>#{expected_result['denominator']}</color>", :inline_format =>true, :align => :center},
			     {:content=> "<color rgb='000000'>#{reported_result['numerator']}/</color><color rgb='AAAAAA'>#{expected_result['numerator']}</color>", :inline_format =>true, :align => :center},
			     {:content=> "<color rgb='000000'>#{reported_result['exclusions']}/</color><color rgb='AAAAAA'>#{expected_result['exclusions']}</color>", :inline_format =>true, :align => :center}]
  end  
end


if data.size > 0 then
fill_color "00FF00"
  pdf.table(data,:cell_style =>{ :border_color => "FFFFFF" })
else 
  fill_color "000000"
  pdf.text "NONE\n\n", :align => :center
end

fill_color "FF0000"
pdf.text "\n"
pdf.stroke_horizontal_rule
data =[]

pdf.text "\nPQRI Validation Errors:\n\n"
if @current_execution.validation_errors
  @current_execution.validation_errors.each do |error|  
    data << [{:content => error, :border_color => "FF0000", :width =>540, :text_color => '000000'}]
    pdf.table(data, :row_colors =>['F7E1E7'])
	  pdf.text "\n"
	  data=[]
  end
end

fill_color '000000'
if data.size > 0 then
  pdf.table(data, :row_colors =>['F7E1E7'])
end