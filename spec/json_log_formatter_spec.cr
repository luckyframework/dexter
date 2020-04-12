require "./spec_helper"

describe Dexter::Formatters::JSONLogFormatter do
  # Ignores Log::Entry#message since Dexter override log methods and set message to ""
  it "formats the context data as JSON and ignores message" do
    io = IO::Memory.new
    entry = build_entry({my_data: "is great!"}, source: "json-test")

    format(io, entry)

    io.to_s.chomp.should eq(
      {severity: "Info", source: "json-test", timestamp: timestamp, my_data: "is great!"}.to_json
    )
  end

  it "merges exception data if present" do
  end
end

private def format(io : IO, entry : Log::Entry)
  Dexter::Formatters::JSONLogFormatter.call(entry, io)
end

private def build_entry(context : NamedTuple, source = "", severity = Log::Severity::Info, exception : Exception? = nil)
  Log.with_context do
    Log.context.set context
    entry = Log::Entry.new \
      source: source,
      message: "",
      severity: severity,
      exception: exception
    entry.timestamp = timestamp
    entry
  end
end

private def timestamp
  Time.utc(2016, 2, 15)
end
