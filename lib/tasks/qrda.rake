namespace :qrda do
  desc "Validate that a QRDA Cat 1 document conforms to the schematron rules set up for it"
  task :validate, [:qrda_file] => :environment do |t, args|
    qrda_path = Pathname.new(args.qrda_file)
    measure_id = qrda_path.dirname.basename.to_s
    measure = Measure.where(hqmf_id: measure_id).first
    if measure.nil?
      puts "Can't find measure with a hqmf_id of #{measure_id}"
    end
    doc = File.read(args.qrda_file)
    errors = Cypress::QrdaUtility.validate_cat_1(doc, [measure])
    errors.reject! { |e| e.msg_type == :warning }

    if errors.empty?
      puts "Valid QRDA Cat 1 file: #{args.qrda_file}"
    else
      errors.each do |error|
        puts 'Message:'
        puts error.message
        puts 'Location:'
        puts error.location
        puts '--------------------------------------------------'
      end
      puts "#{errors.length} errors found for mesure #{measure.nqf_id} in #{args.qrda_file}"
    end
  end
end