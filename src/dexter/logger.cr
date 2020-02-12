require "logger"
require "./formatters/*"

module Dexter
  class Logger < ::Logger
    property log_formatter : Dexter::Formatters::BaseLogFormatter.class

    # The built-in Crystal Logger requires a formatter, but we don't use it.
    # We instead override the `write` method and use our own formatter that
    # accepts a NamedTuple instead of a string
    private UNUSED_FORMATTER = Formatter.new do |_, _, _, _, _|
      # unused
    end

    def initialize(
      @io : IO?,
      @level = Severity::INFO,
      @log_formatter = Dexter::Formatters::JsonLogFormatter,
      @progname = ""
    )
      @formatter = UNUSED_FORMATTER
      @closed = false
      @mutex = Mutex.new
    end

    {% for name in ::Logger::Severity.constants %}
    # Logs *message* if the logger's current severity is lower or equal to `{{name.id}}`.
    def {{name.id.downcase}}(data : NamedTuple) : Nil
      log(Severity::{{name.id}}, data)
    end

    # Logs *message* if the logger's current severity is lower or equal to `{{name.id}}`.
    #
    # Same as `{{ name.id }} but does not require surrounding data with {}:
    #
    # Example: `Dexter::Logger.new(STDOUT).{{ name.id }}(data: "my_data")`
    def {{name.id.downcase}}(**data) : Nil
      log(Severity::{{name.id}}, data)
    end
  {% end %}

    def log(severity : ::Logger::Severity, **data) : Nil
      log(severity: severity, data: data)
    end

    def log(severity : ::Logger::Severity, data : NamedTuple) : Nil
      return if severity < level || !@io
      write(severity, Time.utc, @progname, data)
    end

    # :nodoc:
    def formatter=(value) : Nil
      puts <<-TEXT
      Dexter::Logger ignores 'formatter=' because it uses its own formatter. Please use 'log_formatter=' instead.
      TEXT
    end

    private def write(severity : ::Logger::Severity, datetime : Time, progname, message : String | NamedTuple) : Nil
      io = @io
      return unless io

      data = if message.is_a?(String)
               {message: message}
             else
               message
             end

      progname_to_s = progname.to_s
      @mutex.synchronize do
        log_formatter.new(
          severity: severity,
          timestamp: datetime,
          progname: progname_to_s,
          io: io
        ).format(data)
        io.puts
        io.flush
      end
    end
  end
end
