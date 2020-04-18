require "./spec_helper"

describe Log do
  {% for name, _severity in ::Log::SEVERITY_MAP %}
    it "logs NamedTuple data for '{{ name.id.downcase }}' to 'local' context" do
      entry = log_stubbed do |log|
        log.{{ name.id.downcase }} ->{ {foo: "bar" }}
      end

      entry.context["local"].as_h.transform_values(&.as_s).should eq({"foo" => "bar"})
      entry.message.should eq("")
    end

    it "logs Hash data for '{{ name.id.downcase }}' to 'local' context" do
      entry = log_stubbed do |log|
        log.{{ name.id.downcase }} ->{ {"foo" => "bar" }}
      end

      entry.context["local"].as_h.transform_values(&.as_s).should eq({"foo" => "bar"})
      entry.message.should eq("")
    end
  {% end %}

  it "allows logging data with nil values" do
    entry = log_stubbed do |log|
      log.info ->{ {"foo" => nil} }
    end

    entry.context["local"]["foo"].should eq("")
    entry.message.should eq("")
  end

  it "allows passing an exception" do
    ex = RuntimeError.new
    entry = log_stubbed do |log|
      log.info ex, ->{ {"foo" => nil} }
    end

    entry.exception.should eq(ex)
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
