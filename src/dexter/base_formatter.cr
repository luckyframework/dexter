module Dexter
  abstract struct BaseFormatter
    getter entry, io

    def self.proc
      ::Log::Formatter.new do |entry, io|
        new(entry, io).call
      end
    end

    def initialize(@entry : Log::Entry, @io : IO)
    end

    abstract def call
  end
end
