# frozen_string_literal: true

module Validators
  class TinValidator < QrdaFileValidator
    include Validators::Validator

    def validate(file, options = {})
      aco_measure_ids = Measure.where(hqmf_set_id: { '$in': APP_CONSTANTS['aco_measures_hqmf_set_ids'] }).distinct(:hqmf_id)
      return unless aco_measure_ids.include?(options.task.product_test.measure_ids.first)

      @document = get_document(file)
      expected_tin = options.task.product_test.provider.tin

      # Otherwise, look for the certification ID
      tin_node = @document.at_xpath('//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/' \
                                    "cda:representedOrganization/cda:id[@root='2.16.840.1.113883.4.2']")
      if tin_node
        reported_tin = tin_node['extension']
        unless reported_tin == expected_tin
          msg = "Reported TIN #{reported_tin} does not match Expected TIN #{expected_tin}.  " \
                'You can configure expected TIN using Vendor Preferences.'
          add_warning(msg, file_name: options[:file_name])
        end
      else
        msg = 'TIN should be reported for these measures to support ACO reporting.'
        add_warning(msg, file_name: options[:file_name])
      end
    end
  end
end
