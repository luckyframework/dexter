require "./spec_helper"

describe Log do
  {% for name, _severity in ::Log::SEVERITY_MAP %}
    it "logs NamedTuple data for '{{ name.id.downcase }}'" do
      io = IO::Memory.new
      log = build_log(io)

      Log.with_context do
        log.{{ name.id.downcase }} { {foo: "bar"} }
      end

      io.to_s.chomp.should eq(%({"foo" => "bar"}))
    end
  {% end %}

  it "converts regular message into hash" do
  end

  it "merges regular message into context" do
  end

  it "ignores empty message string" do
  end
end

private def build_log(io = STDOUT)
  backend = Log::IOBackend.new(io)
  backend.formatter = ->(entry : Log::Entry, log_io : IO) {
    log_io << entry.context.to_h
  }
  Log.new("dexter.text", backend: backend, level: :debug)
end
