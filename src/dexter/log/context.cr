class Log::Context
  alias ContextValue = Bool | Float32 | Float64 | Int32 | Int64 | String | Time

  def to_h : Hash(String, ContextValue)
    as_h.transform_values do |v|
      v.raw.as?(ContextValue)
    end.compact
  end
end
