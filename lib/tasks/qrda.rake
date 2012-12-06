namespace :qrda do
  desc "Validate that a QRDA Cat 1 document conforms to the schematron rules set up for it"
  task :validate, [:qrda_file] => :environment do |t, args|
    qrda_path = Pathname.new(args.qrda_file)
    measure_id = qrda_path.dirname.basename.to_s
    measure = Measure.where(nqf_id: measure_id).first
    doc = File.read(args.qrda_file)
    errors = Cypress::QrdaUtility.validate_cat_1(doc, [measure])
    if errors.empty?
      puts "Valid QRDA Cat 1 file"
    else
      errors.each do |error|
        puts 'Message:'
        puts error.message
        puts 'Location:'
        puts error.location
        puts '--------------------------------------------------'
      end
      puts "#{errors.length} errors found"
    end
  end
end