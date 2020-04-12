require "./spec_helper"

describe Log do
  {% for name, _severity in ::Log::SEVERITY_MAP %}
    it "logs NamedTuple data for '{{ name.id.downcase }}'" do
      io = IO::Memory.new
      log = build_log(io)

      log.{{ name.id.downcase }} { {foo: "bar"} }

      io.to_s.chomp.should eq(%({"foo" => "bar"}))
    end
  {% end %}

  it "merges existing context with the log data" do
    io = IO::Memory.new
    log = build_log(io)

    Log.with_context do
      Log.context.set(user: 1)
      log.info { {foo: "bar"} }
    end

    io.to_s.chomp.should eq(%({"user" => 1, "foo" => "bar"}))
  end

  it "converts non-empty String message into key/value data" do
    io = IO::Memory.new
    log = build_log(io)

    log.info { "My message" }

    io.to_s.chomp.should eq(%({"message" => "My message"}))
  end

  it "leaves empty String as-is and does not add it to the context" do
    io = IO::Memory.new
    log = build_log(io)

    log.info { "" }

    io.to_s.chomp.should eq(%({}))
  end

  it "merges String message into context" do
    io = IO::Memory.new
    log = build_log(io)

    Log.with_context do
      Log.context.set(user: 1)
      log.info { "My message" }
    end

    io.to_s.chomp.should eq(%({"user" => 1, "message" => "My message"}))
  end

  it "sets the message to an empty string when passed key/value data" do
    io = IO::Memory.new
    log = build_log(io, ->(entry : Log::Entry, log_io : IO) {
      log_io << entry.message
    })

    log.info { {foo: "bar"} }

    io.to_s.chomp.should eq("")
  end
end

private def build_log(io, formatter : Log::Formatter = raw_context_formatter)
  backend = Log::IOBackend.new(io)
  backend.formatter = formatter
  Log.new("dexter.text", backend: backend, level: :debug)
end

private def raw_context_formatter : Log::Formatter
  ->(entry : Log::Entry, io : IO) {
    io << entry.context.to_h
  }
end
