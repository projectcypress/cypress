module Logging

  @@fallback = nil 

  # Use this for test debugging output when it isn't convenient to set a logger.
  def self.fallback=(stream)
    @@fallback = stream
  end

  def self.fallback
    @@fallback
  end

  def self.included(base)
    base.send(:attr_writer, :logger, :logger_color)
  end

  [:debug, :info, :warn, :error, :fatal].each do |level|
    define_method(level) do |message|
      _log(level, message)
    end
  end

  def logger
    @logger ||= if [:root?, :root].all? { |m| respond_to?(m) }
      root? ? nil : root.logger
    end
  end

  def logger_color
    @logger_color || 32
  end

  private

  def _log(severity, original_message)
    message = "\e[4;#{logger_color};1m#{self.class}\e[0m : #{original_message}"
    if logger
      logger.send(severity, message)
    elsif Logging.fallback
      Logging.fallback.puts "#{severity.to_s.upcase} : #{message}"
    end
  end

end
