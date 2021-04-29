# frozen_string_literal: true

module MeasureRepresenter
  include API::Representer

  property :hqmf_id
  property :cms_id
  property :description
  property :reporting_program_type
  property :category
end
