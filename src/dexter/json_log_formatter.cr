require "json"

module Dexter
  struct JSONLogFormatter < BaseFormatter
    def call
      data = {
        "severity"  => entry.severity.to_s,
        "source"    => entry.source,
        "timestamp" => entry.timestamp,
        "message"   => entry.message,
      }
        .merge(entry.context.as_h)
      if ex = entry.exception
        data = data.merge({"error" => {"class" => ex.class.name, "message" => ex.message, "backtrace" => ex.backtrace?}})
      end

      data
        .compact
        .reject { |_k, v| v.nil? || v.to_s.try(&.empty?) }
        .to_json(io)
    end
  end
end
