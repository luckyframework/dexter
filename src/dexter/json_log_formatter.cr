require "json"

module Dexter
  JSONLogFormatter = ->(entry : Log::Entry, io : IO) {
    JSONLogFormatterImplementation.new(entry, io).call
  }

  struct JSONLogFormatterImplementation
    alias ContextPrimitive = Bool | Float32 | Float64 | Int32 | Int64 | String | Time

    getter entry, io

    def initialize(@entry : Log::Entry, @io : IO)
    end

    def call
      data = {
        "severity"  => entry.severity.to_s,
        "source"    => entry.source,
        "timestamp" => entry.timestamp,
        "message"   => entry.message,
      }
        .merge(entry.context.as_h.transform_values { |v| transform(v.raw) })
      if ex = entry.exception
        data = data.merge({"error" => {"class" => ex.class.name, "message" => ex.message, "backtrace" => ex.backtrace?}})
      end

      data
        .compact
        .reject { |_k, v| v.nil? || v.to_s.try(&.empty?) }
        .to_json(io)
    end

    private def transform(value : Hash)
      value.transform_values do |v|
        transform(v)
      end
    end

    private def transform(value : Array)
      value.map do |v|
        v.raw.as?(ContextPrimitive) || v.to_s
      end
    end

    private def transform(value)
      value.as?(ContextPrimitive) || value.to_s
    end
  end
end
