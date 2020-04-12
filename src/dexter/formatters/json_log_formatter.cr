require "json"

module Dexter
  module Formatters
    JSONLogFormatter = ->(entry : Log::Entry, io : IO) {
      {
        "severity"  => entry.severity.to_s,
        "source"    => entry.source,
        "timestamp" => entry.timestamp,
      }
        .merge(entry.context.to_h)
        .compact
        .to_json(io)
    }
  end
end
