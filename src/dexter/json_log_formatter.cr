require "json"
require "log/json"

module Dexter
  struct JSONLogFormatter < BaseFormatter
    def call
      context_data = entry.context.to_h
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
      data = Hash(String, String | Time | Hash(String, String)).new
      data["severity"] = entry.severity.to_s
      data["source"] = entry.source
      data["timestamp"] = entry.timestamp
      data["data"] = metadata unless entry.data.empty?
      data["message"] = entry.message unless entry.message.empty?
      data
    end

    private def metadata
      Hash(String, String).new.tap do |hash|
        entry.data.each do |key, value|
          hash[key.to_s] = value.to_s
        end
      end
    end

    private def exception_data
      entry.exception.try do |ex|
        {"error" => {"class" => ex.class.name, "message" => ex.message, "backtrace" => ex.backtrace?}}
      end
    end
  end
end
