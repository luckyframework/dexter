require "./spec_helper"

describe Dexter::JSONLogFormatter do
  it "formats the context data as JSON and skips message if empty" do
    io = IO::Memory.new
    entry = build_entry({my_data: "is great!"}, source: "json-test", severity: :debug)

    format(entry, io)

    io.to_s.chomp.should eq(
      {severity: "Debug", source: "json-test", timestamp: timestamp, my_data: "is great!"}.to_json
    )
  end

  it "formats the entry metadata as json" do
    io = IO::Memory.new
    entry = build_entry({my_data: "is great!"}, source: "json-test", severity: :debug, data: Log::Metadata.build({metadata: "is great!", more_data: "more!"}))
    format(entry, io)
    io.to_s.chomp.should eq(
      {severity: "Debug", source: "json-test", timestamp: timestamp, data: {metadata: "is great!", more_data: "more!"}, my_data: "is great!"}.to_json
    )
  end

  it "formats complex types" do
    io = IO::Memory.new
    entry = build_entry({args: [1], params: {foo: "bar"}, other: {arr: [1]}}, source: "json-test", severity: :debug)

    format(entry, io)

    log = JSON.parse(io.to_s.chomp).as_h
    log["args"].as_a.should eq([1])
    log["params"].as_h.should eq({"foo" => "bar"})
    log["other"].as_h.should eq({"arr" => [1]})
  end

  it "prints local context data first" do
    io = IO::Memory.new
    entry = build_entry({foo: "bar", global: true}, source: "json-test", severity: :debug)

    format(entry, io)

    io.to_s.chomp.should eq(
      {severity: "Debug", source: "json-test", timestamp: timestamp, foo: "bar", global: true}.to_json
    )
  end

  it "merge the message if present" do
    io = IO::Memory.new
    entry = build_entry({my_data: "is great!"}, message: "my message")

    format(entry, io)

    log = JSON.parse(io.to_s.chomp).as_h
    log["message"].as_s.should eq("my message")
    log["my_data"].as_s.should eq("is great!")
  end

  it "merges exception data if present" do
    io = IO::Memory.new
    entry = build_entry({my_data: "is great!"}, exception: RuntimeError.new("This is my error"))

    format(entry, io)

    error = JSON.parse(io.to_s.chomp).as_h["error"]
    error["class"].as_s.should eq("RuntimeError")
    error["message"].as_s.should eq("This is my error")
    # Backtace should be nil since error was instantiated manually
    error["backtrace"].as_nil.should be_nil
  end

  it "adds exception backtrace data if present" do
    begin
      # Must raise an error so we get a backtrace to test against.
      raise RuntimeError.new("This is my error")
    rescue e : RuntimeError
      io = IO::Memory.new
      entry = build_entry({my_data: "is great!"}, exception: e)

      format(entry, io)

      error = JSON.parse(io.to_s.chomp).as_h["error"]
      error["backtrace"].as_a.map(&.as_s).should be_a(Array(String))
    end
  end
end

private def format(entry : Log::Entry, io : IO)
  Dexter::JSONLogFormatter.proc.format(entry, io)
end

private def build_entry(context, message = "", source = "", severity : Log::Severity = Log::Severity::Info, data : Log::Metadata = Log::Metadata.empty, exception : Exception? = nil)
  Log.with_context do
    Log.context.set context
    entry = Log::Entry.new \
      source: source,
      message: message,
      severity: severity,
      data: data,
      exception: exception
    entry.timestamp = timestamp
    entry
  end
end

private def timestamp
  Time.utc(2020, 2, 15)
end
