namespace :highlighting do
  task setup: :environment
    task  :handlebars => :setup do |_, args|
      #output = File.open("test_this2.html", 'w')
      #output << HandlebarsTemplates[handlebarTest]{books: data}
      #output.close
      template = File.open("handlebarTest", 'r')
      context = {name:"Michel Koopman", occupation:"developer"}
      templateScript = Handlebars.compile(template)
      html = templateScript(context)
      end
#    rescue Errno::ENOENT => e
#      $stderr.puts "Caught the exception: #{e}"
#      puts "Rake test Caught the exception #(e)"
#      exit -1

    task :highlighting => :setup do |_, args|
     output = File.open("test_this20.html", 'w')
     # output << QdmPatient.new(Patient.first, true).render.html_safe
     # output << QdmPatient.new(Patient.first, false).render.html_safe
     # output << Qrda1R5.new(Patient.first, Measure.first, options).render.html_safe
     measure1 = Measure.all.first
     measure2 = Measure.all.first
     measure3 = Measure.all.first
     measure4 = Measure.all.first
     measure5 = Measure.all.first
     measure6 = Measure.all.first
     measure7 = Measure.all.first
     measure8 = Measure.all.first
     measure9 = Measure.all.first
     resultList = IndividualResult.all
     results = [ resultList[11] ]
     # result1 = Result.new
     #measures = [measure1, measure2, measure3, measure4, measure5, measure6, measure7, measure8, measure9]
      measures = [measure1]
     output << Highlighting.new(measures, results).render
     # output << Measure.new().render.html_safe
     output.close
    end
  rescue Errno::ENOENT => e
    $stderr.puts "Caught the exception: #{e}"
    puts "Rake test Caught the exception #(e)"
    exit -1

  end