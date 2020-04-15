require "log"
require "./base_formatter"
require "./json_log_formatter"

class Log
  SEVERITY_MAP = {
    debug:   Severity::Debug,
    verbose: Severity::Verbose,
    info:    Severity::Info,
    warn:    Severity::Warning,
    error:   Severity::Error,
    fatal:   Severity::Fatal,
  }

  {% for method, severity in SEVERITY_MAP %}
    # Logs a `String` message or key/value data using a `NamedTuple`
    #
    # ```crystal
    # Log.{{ method.id }} { {path: "/comments", status: 200} }
    # Log.{{ method.id }} { "My mesage" }
    # ```
    #
    # You can also pass an exception:
    #
    # ```crystal
    # Log.{{ method.id }}(exception) { "My mesage" }
    # ```
    def {{method.id}}(*, exception : Exception? = nil)
      return unless backend = @backend
      severity = Severity.new({{severity}})
      return unless level <= severity

      block_result = yield

      if block_result.is_a?(NamedTuple)
        Log.with_context do
          Log.context.set(block_result)
          # Print empty message since the data is assigned to the context
          write_entry_to_io(backend, severity, message: "", exception: exception)
        end
      else
        # This falls back to the regular Crystal log behavior and
        # assigns the message String
        write_entry_to_io(backend, severity, message: block_result.to_s, exception: exception)
      end
    end
  {% end %}

  private def write_entry_to_io(backend : Backend, severity : Severity, message : String, exception : Exception?) : Nil
    entry = Entry.new @source, severity, message, exception
    backend.write entry
  end
end
