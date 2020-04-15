module Dexter
  abstract struct BaseFormatter
    alias ContextPrimitive = Bool | Float32 | Float64 | Int32 | Int64 | String | Time

    getter entry, io

    def self.proc
      ->(entry : Log::Entry, io : IO) {
        new(entry, io).call
      }
    end

    def initialize(@entry : Log::Entry, @io : IO)
    end
  end
end
