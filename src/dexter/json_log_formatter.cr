require "json"

module Dexter
  module Formatters
    JSONLogFormatter = ->(entry : Log::Entry, io : IO) {
      ex = entry.exception
      data = {
        "severity"  => entry.severity.to_s,
        "source"    => entry.source,
        "timestamp" => entry.timestamp,
      }
        .merge(entry.context.to_h)
      if ex
        data = data.merge({"error" => {"class" => ex.class.name, "message" => ex.message, "backtrace" => ex.backtrace?}})
      end

      unless entry.message.empty?
        data = data.merge({"message" => entry.message})
      end

      data
        .compact
        .to_json(io)
    }
  end
end
