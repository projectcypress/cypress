class CQMDataElement
  include Mongoid::Document
  field :qdm_type, :type => String
  field :data_element_vs_oid, :type => String
  field :data_element_drc, :type => String
  embeds_many :data_element_attributes, class_name: 'CQMDataElementAttribute'
  field :cms_measures, :type => Array

  def cqm_data_element_for_measure(cms_id)
    segments = CQMDataElementSegment.where(cqm_id: cms_id)
    collect_data_element_array(segments, cms_id)
  end

  def cqm_data_element_for_qdm_type(qdm_type)
    segments = CQMDataElementSegment.where(qdm_type: qdm_type)
    collect_data_element_array(segments)
  end

  def cqm_data_element_for_qdm_type_and_valueset(qdm_type, data_element_vs_oid)
    segments = CQMDataElementSegment.where(qdm_type: qdm_type, data_element_vs_oid: data_element_vs_oid)
    collect_data_element_array(segments)
  end

  def cqm_data_element_for_valueset(data_element_vs_oid)
    segments = CQMDataElementSegment.where(data_element_vs_oid: data_element_vs_oid)
    collect_data_element_array(segments)
  end

  def cqm_data_element_for_attribute_valueset(attribute_vs_oid)
    segments = CQMDataElementSegment.where(attribute_vs_oid: attribute_vs_oid)
    collect_data_element_array(segments)
  end

  def collect_data_element_array(segments, cms_id = nil)
    qdm_vs_map = segments.to_a.map { |seg| { qdm_type: seg.qdm_type, data_element_vs_oid: seg.data_element_vs_oid } }.uniq
    data_element_array = []
    qdm_vs_map.each do |qdm_vs|
      data_element_array << data_element_for_qdm_type_valueset_and_measure(qdm_vs[:qdm_type], qdm_vs[:data_element_vs_oid], cms_id)
    end
    data_element_array
  end

  def data_element_for_qdm_type_valueset_and_measure(qdm_type, valueset, cms_id = nil)
    if cms_id
      data_element_from_segments(CQMDataElementSegment.where(qdm_type: qdm_type, data_element_vs_oid: valueset, cqm_id: cms_id))
    else
      data_element_from_segments(CQMDataElementSegment.where(qdm_type: qdm_type, data_element_vs_oid: valueset))
    end
  end

  def data_element_from_segments(data_element_segments)
    first_data_element = data_element_segments.first
    if first_data_element.data_element_vs_oid.include?('.')
      cqm_data_element = CQMDataElement.new(qdm_type: first_data_element.qdm_type,
                                            data_element_vs_oid: first_data_element.data_element_vs_oid,
                                            cms_measures: [])
    else
      cqm_data_element = CQMDataElement.new(qdm_type: first_data_element.qdm_type,
                                            data_element_drc: first_data_element.data_element_vs_oid,
                                            cms_measures: [])
    end
    data_element_segments.each do |des|
      cqm_data_element.cms_measures << des.cqm_id unless cqm_data_element.cms_measures.include? des.cqm_id
      stored_att = cqm_data_element.data_element_attributes.where(attribute_name: des.attribute_name).first
      if stored_att && des.attribute_vs_oid
        if des.attribute_vs_oid.include?('.')
          stored_att.attribute_vs.nil? ? stored_att.attribute_vs = [des.attribute_vs_oid] : stored_att.attribute_vs << des.attribute_vs_oid
        else
          stored_att.attribute_drc.nil? ? stored_att.attribute_drc = [des.attribute_vs_oid] : stored_att.attribute_drc << des.attribute_vs_oid
        end
      else
        dea = CQMDataElementAttribute.new(attribute_name: des.attribute_name)
        dea.attribute_vs = [des.attribute_vs_oid] if des.attribute_vs_oid && des.attribute_vs_oid.include?('.')
        dea.attribute_drc = [des.attribute_vs_oid] if des.attribute_vs_oid && !des.attribute_vs_oid.include?('.')
        cqm_data_element.data_element_attributes << dea
      end
    end
    cqm_data_element
  end

end

class CQMDataElementAttribute
  include Mongoid::Document
  field :attribute_name, :type => String
  field :attribute_vs, :type => Array
  field :attribute_drc, :type => Array
end
