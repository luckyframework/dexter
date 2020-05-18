class Log; end

require "json"
require "log/json"

module Dexter
  struct JSONLogFormatter < BaseFormatter
    def call
      context_data = Hash(String, ::Log::Metadata::Value).new
      entry.context.each do |key, value|
        context_data[key.to_s] = value
      end

      local_data = context_data.delete("local").try(&.as_h)
      data = default_data

      if local_data
        data = data.merge(local_data)
      end

      data = data.merge(context_data)

      exception_data.try do |exception_data_|
        data = data.merge(exception_data_)
      end

      data
        .compact
        .to_json(io)
    end

    private def default_data
      data = {
        "severity"  => entry.severity.to_s,
        "source"    => entry.source,
        "timestamp" => entry.timestamp,
      }
      data["message"] = entry.message unless entry.message.empty?
      data
    end

    private def exception_data
      entry.exception.try do |ex|
        {"error" => {"class" => ex.class.name, "message" => ex.message, "backtrace" => ex.backtrace?}}
      end
    end
  end
end
