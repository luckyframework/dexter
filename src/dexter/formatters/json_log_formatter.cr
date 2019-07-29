require "json"
require "./base_log_formatter"

module Dexter
  module Formatters
    struct JsonLogFormatter < BaseLogFormatter
      def format(data) : Nil
        {severity: severity.to_s, timestamp: timestamp}.merge(data).to_json(io)
      end
    end
  end
end
