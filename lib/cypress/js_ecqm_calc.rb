require 'bunny'
require 'json'

module Cypress
    class JsEcqmCalc
        
        attr_accessor :patient_ids, :measure_ids, :options, :lock, :response,
        :connection, :channel, :queue, :reply_queue, :exchange, :call_id, :condition
        
        def initialize (patient_ids, measure_ids, options)
            # @hds_record_converter = CQM::Converter::HDSRecord.new
            @connection = Bunny.new(automatically_recover: false)
            @connection.start
            @channel = connection.create_channel
            @queue=channel.queue('calculation_queue', durable: true)
            
            @patient_ids = patient_ids
            @measure_ids = measure_ids
            @options = options
        end
        
        def sync_job
            setup_reply_queue
            @exchange = @channel.default_exchange

            @call_id = SecureRandom.uuid
            
            message = JSON.dump({ patient_ids: @patient_ids,
                                  measure_ids: @measure_ids,
                                  options: @options,
                                  type: 'sync',
                                  reply_to: @reply_queue.name })
            
            @exchange.publish(message,
                routing_key: 'calculation_queue',
                correlation_id: @call_id,
                reply_to: @reply_queue.name)
                
                @lock.synchronize { @condition.wait(@lock) }
                
                response
            end 
            
            def async_job
                message = JSON.dump({ patient_ids: @patient_ids,
                                      measure_ids: @measure_ids,
                                      options: @options,
                                      type: 'async' })
                @queue.publish(message, persistent: true)
                
                puts " [x] Sent #{message}"
            end 
            
            def stop
                @channel.close
                @connection.close
            end
            
            private
            
            def setup_reply_queue
                @lock = Mutex.new
                @condition = ConditionVariable.new
                that = self
                @reply_queue = channel.queue('', exclusive: true)
                
                @reply_queue.subscribe do |_delivery_info, properties, payload|
                    if properties[:correlation_id] == that.call_id
                        that.response = payload.to_s
                        
                        # sends the signal to continue the execution of #call
                        that.lock.synchronize { that.condition.signal }
                    end
                end
            end
            
            
        end
    end
        