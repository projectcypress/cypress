class CQMDataElementSegment
  include Mongoid::Document

  field :qdm_type, :type => String
  field :data_element_vs_oid, :type => String
  field :attribute_name, :type => String
  field :attribute_vs_oid, :type => String
  field :cqm_id, :type => String

  # These method are current here to populate the database with the data element segments
  def from_csv
    csv_text = File.read('script/data_element_library.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv.each do |row|
      data_element_segment_from_row(row)
    end
  end

  def data_element_segment_from_row(row)
    CQMDataElementSegment.new(qdm_type: row[0], data_element_vs_oid: row[1], attribute_name: row[2], attribute_vs_oid: row[3], cqm_id: row[4]).save
  end

end