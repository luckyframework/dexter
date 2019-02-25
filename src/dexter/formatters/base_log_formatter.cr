module Dexter
  module Formatters
    abstract struct BaseLogFormatter
      private getter severity, timestamp, progname, io, data

      def initialize(
        @severity : ::Logger::Severity,
        @timestamp : Time,
        @progname : String,
        @io : IO
      )
      end

      abstract def format(data : NamedTuple) : Void
    end
  end
end
