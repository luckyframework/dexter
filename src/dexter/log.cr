require "log"
require "./formatters/*"
require "./log/context"

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
    # Logs key/value data using NamedTuple
    #
    # ```crystal
    # Log.{{ method.id }} { {path: "/comments", status: 200} }
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
        write_entry_to_io(backend, severity, message: "", exception: exception)
      end
    end
  {% end %}

  private def write_entry_to_io(backend : Backend, severity : Severity, message : String, exception : Exception?) : Nil
    entry = Entry.new @source, severity, message, exception
    backend.write entry
  end
end
