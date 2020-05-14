{% if compare_versions(Crystal::VERSION, "0.35.0-0") >= 0 %}
{% else %}
  class Log::Context
    def to_json(builder : JSON::Builder) : Nil
      @raw.to_json builder
    end

    # TODO: Remove this once https://github.com/crystal-lang/crystal/pull/9104 is merged
    # and released
    def initialize(raw : Nil)
      @raw = ""
    end
  end
{% end %}
