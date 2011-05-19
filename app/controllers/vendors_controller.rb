class VendorsController < ApplicationController

  def index
    @incomplete_vendors = Vendor.all(:conditions => {'passed'=>{'$in'=>[nil,false]}})
    @complete_vendors = Vendor.all(:conditions => {'passed'=>true})
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def create
    vendor = Vendor.new(params[:vendor])
    test = Test.new(:effective_date=>Time.gm(2010,12,31).to_i)
    test.measure_ids = ['0001', '0002']
    vendor.tests << test
    vendor.save!
    randomized_records(100, vendor.tests[0])
    redirect_to :action => 'index'
  end
  
  def show
    @vendor = Vendor.find(params[:id])
    @test = @vendor.tests.last
    @measures = measure_defs(@test.measure_ids)
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes!(params[:vendor])
    render :action => 'show'
  end
  
  private
  
  def measure_defs(measure_ids)
    measure_ids.collect do |measure_id|
      Measure.where(id: measure_id).order_by([[:sub_id, :asc]]).all()
    end.flatten
  end
  
  def randomized_records(number, test)
    templates = []
    Dir.glob(Rails.root.join('db', 'templates', '*.json.erb')).each do |file|
      templates << File.read(file)
    end
    
    processed_measures = {}
    QME::QualityMeasure.all.each_value do |measure_def|
      measure_id = measure_def['id']
      if !processed_measures[measure_id]
        QME::Importer::PatientImporter.instance.add_measure(measure_id, QME::Importer::GenericImporter.new(measure_def))
        processed_measures[measure_id]=true
      end
    end

    number.times do
      template = templates[rand(templates.length)]
      generator = QME::Randomizer::Patient.new(template)
      json = JSON.parse(generator.get())
      patient_record_hash = QME::Importer::PatientImporter.instance.parse_hash(json)
      patient_record_hash['test_id'] = test._id
      patient_record = Record.new(patient_record_hash)
      patient_record.save!
    end    
  end
end
