require "./spec_helper"

describe Log do
  {% for name, _severity in ::Log::SEVERITY_MAP %}
    it "logs NamedTuple data for '{{ name.id.downcase }}'" do
      entry = log_stubbed do |log|
        log.{{ name.id.downcase }} { {foo: "bar" }}
      end

      entry.context.as_h.transform_values(&.as_s).should eq({"foo" => "bar"})
      entry.message.should eq("")
    end
  {% end %}

  it "merges existing context with the NamedTuple data" do
    entry = Log.with_context do
      Log.context.set(user: 1)
      log_stubbed do |log|
        log.info { {foo: "bar"} }
      end
    end

    entry.context.as_h.transform_values do |v|
      v.as_s? || v.as_i
    end.should eq({"user" => 1, "foo" => "bar"})
    entry.message.should eq("")
  end

  it "leaves message String as-is and does not add it to the context" do
    entry = log_stubbed do |log|
      log.info { "my message" }
    end

    entry.message.should eq("my message")
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
