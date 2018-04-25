require 'bunny'
require 'json'

module Cypress
    class Calculator

        attr_accessor :patient_ids, :measure_ids, :options

        def initialize (patient_ids, measure_ids, options)
            @hds_record_converter = CQM::Converter::HDSRecord.new
            connection = Bunny.new(automatically_recover: false)
            connection.start
            channel = connection.create_channel
            queue=channel.queue('calculation_queue', durable: true)

            message =  JSON.dump({patient_ids: patient_ids, measure_ids: measure_ids, options: options})
            queue.publish(message, persistent: true)

            puts " [x] Sent #{message}"

            connection.close
        end
    end
end