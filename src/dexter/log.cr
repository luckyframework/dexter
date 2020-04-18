require "log"
require "./log/context"
require "./base_formatter"
require "./json_log_formatter"

class Log
  def dexter : Dexter
    Dexter.new(self)
  end

  struct Dexter
    SEVERITY_MAP = {
      debug:   Severity::Debug,
      verbose: Severity::Verbose,
      info:    Severity::Info,
      warn:    Severity::Warning,
      error:   Severity::Error,
      fatal:   Severity::Fatal,
    }

    getter log

    def initialize(@log : ::Log)
    end

    # Temporarily reconfigure a Log
    #
    # This is mostly helpful when running tests for your log messages. This can
    # make sure you are logging what you expect to log.
    #
    # If you leave off args the method will yield an `IO::Memory` and set the
    # level to `Debug` so it logs all messages.
    #
    # There are also options to configure the `IO`, `Log::Severity`, or
    # `Log::Formatter` used.
    #
    # Once the block ends or raises an exception the Log's configuration will
    # be reverted to its original state.
    #
    # ## Examples
    #
    # ```crystal
    # MyShard::Log.dexter.temp_config do |log_io|
    #   MyShard::Log.info { "log me" }
    #   log_io.to_s.should contain("log me")
    # end
    #
    # my_own_io = IO::Memory.new
    # MyShard::Log.dexter.temp_config(my_own_io) do
    #   MyShard::Log.info { "log me" }
    #   my_own_io.to_s.should contain("log me")
    # end
    #
    # formatter = ::Log::Formatter.new do |entry, io|
    #   io << entry.severity
    # end
    #
    # MyShard::Log.dexter.temp_config(level: :info, formatter: formatter) do |log_io|
    #   MyShard::Log.info { "log me" }
    #   # This is a useless test, but is here to show what can be done
    #   # with the formatter option. In this case, just log severity:
    #   my_own_io.to_s.chomp.should eq("Info")
    # end
    # ```
    #
    # You can use any combination of `io`, `level`, `formatter`. All are optional.
    def temp_config(io : IO = IO::Memory.new, level : ::Log::Severity = Log::Severity::Debug, formatter : ::Log::Formatter? = nil)
      io ||= IO::Memory.new
      log_class = ::Log.for(log.source)
      original_backend = log_class.backend
      original_level = log_class.level
      begin
        backend = Log::IOBackend.new(io)
        if formatter
          backend.formatter = formatter
        end

        log_class.level = level
        log_class.backend = backend
        yield io
      ensure
        log_class.backend = original_backend
        log_class.level = original_level
      end
    end

    {% for method, severity in SEVERITY_MAP %}
      # Logs key/value data in the Log::Context under the 'local' key
      #
      # ```crystal
      # Log.dexter.{{ method.id }} { {path: "/comments", status: 200 }}
      # ```
      #
      # You can also pass an exception:
      #
      # ```crystal
      # Log.dexter.{{ method.id }}(exception) { { query: "SELECT *" } }
      # ```
      def {{method.id}}(*, exception : Exception? = nil, &block : -> NamedTuple | Hash)
        return unless backend = log.backend
        severity = Severity.new({{severity}})
        return unless log.level <= severity

        block_result = yield

        Log.with_context do
          Log.context.set(local: block_result)
          log.{{method.id}}(exception: exception) { "" }
        end
      end
    {% end %}
  end
end
