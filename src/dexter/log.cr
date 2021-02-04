require "log"
require "./base_formatter"
require "./json_log_formatter"

class Log
  getter backend
end

class Log::Builder
  def dexter_unbind(source : String)
    @mutex.synchronize do
      each_log do |log|
        if Builder.matches(log.source, source)
          @bindings = @bindings.reject do |b|
            b.source == log.source
          end
          log.backend = nil
          log.initial_level = :none
        end
      end
    end
  end
end

class Log
  def dexter : Dexter
    Dexter.new(self)
  end

  def self.dexter : Dexter
    Dexter.new(Log.for(""))
  end

  struct Dexter
    SEVERITY_MAP = {
      debug:  Severity::Debug,
      info:   Severity::Info,
      notice: Severity::Notice,
      warn:   Severity::Warn,
      error:  Severity::Error,
      fatal:  Severity::Fatal,
    }

    getter log

    def initialize(@log : ::Log)
    end

    # Configure a Log and all child logs
    #
    # This is a type-safe and simpler alternative to using `Log.builder.bind`.
    # Rather than pass a string `source` you can configure a log using
    # its class.
    #
    # The backend can be left off and it will use the log's existing backend or
    # a new `Log::IOBackend`
    #
    # It also sets all child logs to the same configuration since this is
    # the most common way to configure logs. If you want to configure a log and
    # none of its children it is best to set the `level` or `backend` directly:
    #
    # ```
    # MyShard::Log.level = :error
    # MyShard::Log.backend = MyCustomBackend.new
    # ```
    #
    # ## Examples:
    #
    # ```
    # # Configure all logs.
    # # Similar to `Log.builder.bind "*"`
    # Log.dexter.configure(:info, backend)
    #
    # # Configure Avram::Log and all child logs
    # # Similar to `Log.builder.bind "avram.*"
    # Avram::Log.dexter.configure(:warn)
    #
    # # Can further customize child Logs
    # Avram::QueryLog.dexter.configure(:none)
    # Avram::FailedQueryLog.dexter.configure(:info, SomeOtherBackend.new)
    # ```
    def configure(severity : Log::Severity, backend : Log::Backend) : Nil
      ::Log.builder.dexter_unbind(source_for_bind)
      ::Log.builder.bind(source_for_bind, severity, backend)
    end

    # :nodoc:
    def configure(severity : Log::Severity) : Nil
      backend = log.backend || ::Log::IOBackend.new
      configure(severity, backend)
    end

    private def source_for_bind : String
      if log.source.empty?
        "*"
      else
        "#{log.source}.*"
      end
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
    # ```
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
    def temp_config(io : IO = IO::Memory.new, level : ::Log::Severity = Log::Severity::Debug, formatter : ::Log::Formatter? = nil) : Nil
      # TODO Log.capture from "log/spec" module

      log_class = ::Log.for(log.source)
      original_backend = log_class.backend
      original_level = log_class.level
      begin
        backend = Log::IOBackend.new(io)
        {% if compare_versions(Crystal::VERSION, "0.36.0-0") >= 0 %}
          backend.dispatcher = Log::Dispatcher.for(:sync)
        {% end %}
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
      # ```
      # Log.dexter.{{ method.id }} { {path: "/comments", status: 200 }}
      # ```
      #
      # You can also pass an exception:
      #
      # ```
      # Log.dexter.{{ method.id }}(exception) { { query: "SELECT *" } }
      # ```
      def {{method.id}}(*, exception : Exception? = nil, &block : -> NamedTuple | Hash) : Nil
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
