require "json"
require "./base_log_formatter"

module Dexter
  module Formatters
    class JsonLogFormatter < BaseLogFormatter
      def format(
        severity : ::Logger::Severity,
        timestamp : Time,
        progname : String,
        data,
        io : IO
      ) : Void
        {severity: severity.to_s, timestamp: timestamp}.merge(data).to_json(io)
      end
    end
  end
end
