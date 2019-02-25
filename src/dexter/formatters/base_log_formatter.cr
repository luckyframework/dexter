module Dexter
  module Formatters
    abstract class BaseLogFormatter
      abstract def format(
        severity : ::Logger::Severity,
        timestamp : Time,
        progname : String,
        data : NamedTuple,
        io : IO
      ) : Void
    end
  end
end
