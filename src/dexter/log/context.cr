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
