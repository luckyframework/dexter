require "json"

module Dexter
  struct JSONLogFormatter < BaseFormatter
    def call
      data = default_data.merge(entry.context.as_h)

      exception_data.try do |exception_data_|
        data = data.merge(exception_data_)
      end

      data
        .compact
        .reject { |_k, v| v.nil? || v.to_s.try(&.empty?) }
        .to_json(io)
    end

    private def default_data
      {
        "severity"  => entry.severity.to_s,
        "source"    => entry.source,
        "timestamp" => entry.timestamp,
        "message"   => entry.message,
      }
    end

    private def exception_data
      entry.exception.try do |ex|
        {"error" => {"class" => ex.class.name, "message" => ex.message, "backtrace" => ex.backtrace?}}
      end
    end
  end
end
