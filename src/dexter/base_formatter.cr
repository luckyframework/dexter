module Dexter
  abstract struct BaseFormatter
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
