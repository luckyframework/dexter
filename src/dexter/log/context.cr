class Log::Context
  def to_json(builder : JSON::Builder) : Nil
    @raw.to_json builder
  end
end
