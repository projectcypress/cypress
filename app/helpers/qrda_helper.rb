# frozen_string_literal: true

module QrdaHelper
  def measure_ids_from_cat_1_file(doc)
    measure_ids = doc.xpath("//cda:entry/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98']]" \
      "/cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']" \
      "/cda:id[@root='2.16.840.1.113883.4.738']/@extension")
    return nil unless measure_ids

    measure_ids.map { |m_id| m_id.value.upcase }
  end

  def measure_ids_from_cat_3_file(doc)
    measure_ids = doc.xpath("//cda:entry/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1']]" \
      "/cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']" \
      "/cda:id[@root='2.16.840.1.113883.4.738']/@extension")
    return nil unless measure_ids

    # This is left as the xpath node so the location can be used in the error message
    measure_ids
  end
end
