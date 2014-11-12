# TestPopulations are subsets of the Master Patient List. Each Test that is executed for a Product uses a TestPopulation
# to keep track of the Records who will be considered in measure calculation.

class PatientPopulation
  include Mongoid::Document

  belongs_to :product_test
  belongs_to :user
  has_and_belongs_to_many :records

  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :patient_ids, type: Array

  validates_presence_of :id
  validates_presence_of :name
  validates_presence_of :patient_ids

  def self.installed
    PatientPopulation.order_by([["name", :asc]]).to_a
  end

  def self.min_coverage(measures, bundle)
    bundle_id = (bundle.kind_of? Bundle)? bundle.id : bundle
    bundle = (bundle.kind_of? Bundle)? bundle : Bundle.find(bundle)
    # Get a hash of all measures requested, each with its own list of patients who are in that measure's numerator
   measures_to_patients = MONGO_DB.command(:group=>{:ns=>'patient_cache',
                                           :key => {"value.measure_id"=>1, "value.sub_id"=>1, "value.test_id"=>1},
                                           :cond => {"bundle_id"=>bundle_id, "value.test_id"=>nil,
                                                     "$or" => [{"value.NUMER" => {"$gt"=>0}},
                                                               {"value.MSRPOPL" => {"$gt"=>0}}],
                                                                "value.measure_id"=>{"$in"=>measures},
                                                                "value.effective_date" => bundle.effective_date},
                                           :initial => {:patients => []},
                                           "$reduce"=> 'function(o,prev){prev.patients.push(o.value.medical_record_id);}'})["retval"]

  # Get a hash of all measures requested, each with its own list of patients who are in that measure's numerator
   denominator_m_to_p = MONGO_DB.command(:group=>{:ns=>'patient_cache',
                                           :key => {"value.measure_id"=>1, "value.sub_id"=>1, "value.test_id"=>1},
                                           :cond => {"bundle_id"=>bundle_id,
                                                     "value.test_id"=>nil, "value.NUMER"=> 0, "value.DENOM"=>{"$gt"=>0},
                                                     "value.measure_id"=>{"$in"=>measures},
                                                     "value.effective_date" => bundle.effective_date},
                                           :initial => {:patients => []},
                                           "$reduce"=> 'function(o,prev){prev.patients.push(o.value.medical_record_id);}'})["retval"]

# Get a hash of all measures requested, each with its own list of patients who are in that measure's numerator
   exclusions_m_to_p = MONGO_DB.command(:group=>{:ns=>'patient_cache',
                                           :key => {"value.measure_id"=>1, "value.sub_id"=>1, "value.test_id"=>1},
                                           :cond => {"bundle_id"=>bundle_id,
                                                     "value.test_id"=>nil, "value.NUMER"=> 0,
                                                     "value.DENEX"=> {"$gt"=>0},"value.measure_id"=>{"$in"=>measures},
                                                     "value.effective_date" => bundle.effective_date},
                                           :initial => {:patients => []},
                                           "$reduce"=> 'function(o,prev){prev.patients.push(o.value.medical_record_id);}'})["retval"]

    # Order the measures by the amount of related patients, fewest to most
    measures_to_patients.sort! {|a,b|
      al = a ? a['patients'].length : 0
      bl = b ? b['patients'].length : 0
      al <=> bl
    }

    # Break off a new hash of patients, each with its own list of measures to which they belong
    patients = {}
    measures_to_patients.each do |val|
      val["patients"].each do |p|
         patients[p] ||= []
         entry = [val["value.measure_id"],val["value.sub_id"]]
         patients[p].push entry unless patients[p].index(entry)
      end
    end
    #mix up the list, this will randomize the number of paitents for a test by not placing the
    measures_to_patients.shuffle

    p_list = []
    m_list = []
    measures_to_patients.each do |val|
      entry = [val["value.measure_id"],val["value.sub_id"]]
      unless m_list.index(entry)
        m_list.push(entry)
        patient = nil
        # Find the patient that is most "valuable", i.e. has the longest list of measures in which they are included
        val["patients"].each do |p|
          patient ||= p
          patient = (patients[patient].length < patients[p].length) ? p : patient
        end
        p_list.push(patient)
        m_list.concat( patients[patient] )
      end
    end
# add an extra person to the denominator for each measure
    denominator_m_to_p.each do |val|

       # as long as there is one from the denom only set in the list there is no need to add another
       if (val["patients"]  & p_list).empty?
         p =  val["patients"].sample
          if p
            p_list.push(p)
          end
      end
    # add to the patient list to colelct overflow
     val["patients"].each do |p|
         patients[p] ||= []
         entry = [val["value.measure_id"],val["value.sub_id"]]
         patients[p].push entry unless patients[p].index(entry)
      end
    end

# add an extra person to the exclusions for each measure if one exists
    exclusions_m_to_p.each do |val|
       # as long as there is one from the denom only set in the list there is no need to add another
       if (val["patients"]  & p_list).empty?
         p =  val["patients"].sample
          if p
            p_list.push(p)
          end
      end
    #add to the patient list to collect overflow
     val["patients"].each do |p|
         patients[p] ||= []
         entry = [val["value.measure_id"],val["value.sub_id"]]
         patients[p].push entry unless patients[p].index(entry)
      end

    end

    p_list.uniq!
    { :minimal_set => p_list, :overflow => patients.keys - p_list }
 end
end
