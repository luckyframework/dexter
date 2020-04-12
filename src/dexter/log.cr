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
        # Add string message to context as {message: "the message"}
        Log.with_context do
          Log.context.set(message: block_result)
          # Always set entry message to blank since it is now part of the context
          write_entry_to_io(backend, severity, message: "", exception: exception)
        end
      end
    end
  {% end %}

  private def write_entry_to_io(backend : Backend, severity : Severity, message : String, exception : Exception?) : Nil
    entry = Entry.new @source, severity, message, exception
    backend.write entry
  end
end
