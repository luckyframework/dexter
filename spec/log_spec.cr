require "./spec_helper"

describe Log do
  {% for name, _severity in Log::Dexter::SEVERITY_MAP %}
    describe "{{ name.id.downcase }}" do
      it "logs NamedTuple data for '{{ name.id.downcase }}' to 'local' context" do
        entry = log_stubbed do |log|
          log.dexter.{{ name.id.downcase }} { {foo: "bar" }}
        end

        entry.context["local"].as_h.transform_values(&.as_s).should eq({"foo" => "bar"})
        entry.message.should eq("")
      end

      it "logs Hash data for '{{ name.id.downcase }}' to 'local' context" do
        entry = log_stubbed do |log|
          log.dexter.{{ name.id.downcase }} { {"foo" => "bar" }}
        end

        entry.context["local"].as_h.transform_values(&.as_s).should eq({"foo" => "bar"})
        entry.message.should eq("")
      end
    end
  {% end %}

  it "allows logging data with nil values" do
    entry = log_stubbed do |log|
      log.dexter.info { {"foo" => nil} }
    end

    entry.context["local"]["foo"].should eq("")
    entry.message.should eq("")
  end

  it "allows passing an exception" do
    ex = RuntimeError.new
    entry = log_stubbed do |log|
      log.dexter.info(exception: ex) { {"foo" => nil} }
    end

    entry.exception.should eq(ex)
  end

  describe "#temp_config" do
    it "reconfigures the log to use an IO::Memory and :debug" do
      original_backend = Log::IOBackend.new(IO::Memory.new)
      log = Log.for("temp_config")
      ::Log.builder.bind(log.source, :none, original_backend)

      log.dexter.temp_config do |log_io|
        log.info { "log me" }
        log.level.should eq(Log::Severity::Debug)
        log_io.to_s.should contain("log me")
      end

      log.level.should eq(Log::Severity::None)
      log.backend.should eq(original_backend)
    end

    it "allows reconfiguring level and backend" do
      original_io = IO::Memory.new
      formatter = ::Log::Formatter.new { |_entry, io| io << "original formatter" }
      backend = ::Log::IOBackend.new(original_io)
      backend.formatter = formatter
      log = Log.for("temp_config_with_options")
      ::Log.builder.bind(log.source, :none, backend)
      log.level.should eq(::Log::Severity::None)

      new_formatter = ::Log::Formatter.new { |_entry, io| io << "overridden formatter" }
      log.dexter.temp_config(level: :info, formatter: new_formatter) do |log_io|
        log.info { "unused" }
        log.level.should eq(Log::Severity::Info)
        log_io.to_s.should contain("overridden formatter")
      end

      # Test that everything reverts back
      log.level.should eq(::Log::Severity::None)
      log.level = :info
      log.info { "unused" }
      original_io.to_s.should contain("original formatter")
    end
  end
end

private class StubbedBackend < Log::Backend
  getter! entry : Log::Entry?

  def write(@entry) : Log::Entry
  end
end

private def log_stubbed : Log::Entry
  backend = StubbedBackend.new
  log = Log.new("dexter.text", backend: backend, level: :debug)
  yield log
  backend.entry
end
