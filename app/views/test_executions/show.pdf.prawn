require 'version'


pdf.image "#{Rails.root}/app/assets/images/cypress_logo.png", :height => 30, :width => 115, :at => [10, 725]
pdf.text_box "Test Results Produced by Project Cypress #{Cypress::Version.current} - projectcypress.org", :at => [165, 715]
stroke_color 'AAAAAA'
pdf.stroke_rounded_rectangle [0,700], 540, 85, 8
pdf.formatted_text_box [
  {:text =>"Candidate EHR:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.vendor.name}\n"},
  {:text =>"Vendor ID:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.vendor.vendor_id}\n" },
  {:text =>"EHR POC:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.vendor.poc}\n"},
  {:text =>"E-mail:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.vendor.email}\n"},
  {:text =>"Phone:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.vendor.tel}\n"}
], :at=> [10, 690]
pdf.text "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

pdf.stroke_rounded_rectangle [0,600], 540, 60 , 8
pdf.formatted_text_box [
  {:text =>"Proctor:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.user.first_name} #{@test_execution.product_test.user.last_name}\n"},
  {:text =>"E-mail:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.user.email}\n" },
  {:text =>"Phone:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.user.telephone}\n"}
], :at=> [10, 590]

if @test_execution.required_modules
  (n,v) = @test_execution.required_modules.first
  @test_execution.required_modules.delete(n)
  modules="Modules: #{n}: #{v}"
  @test_execution.required_modules.each do |name,version|
    modules =  modules +", "+ name + ": " + version
  end
else
  modules = "Modules:"
end 

pdf.stroke_rounded_rectangle [0,525], 540, 65 , 8
pdf.formatted_text_box [
  {:text =>"Product:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.name}\n"},
  {:text => "Product Version:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.product.version}\n"},
  {:text => "#{modules.slice(0, modules.index(':')+1)}", :color => '666666', :size => 10},
  {:text =>" #{modules.slice(modules.index(':') + 2, modules.length)}"},
], :at=> [10, 515]

pdf.stroke_rounded_rectangle [0,450], 540, 45 , 8
pdf.formatted_text_box [
  {:text =>"Test:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.product_test.name}\n"},
  {:text =>"Run at:", :color => '666666', :size => 10},{ :text =>" #{@test_execution.execution_date}\n" }
], :at=> [10, 440]

if @test_execution.product_test.notes
  pdf.text "Notes:"
  @test_execution.product_test.notes.each do |note|
    pdf.text "#{note.time.strftime('%m/%d/%Y')}: #{note.text}\n"
  end
  pdf.text "\n"
end

pdf.stroke_horizontal_rule
pdf.text "\n"

prawn_document do |pdf|
binding.pry
  render test_execution_template(@test_execution), :pdf => pdf
  pdf.text "something else"
end

