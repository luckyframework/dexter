require "log"
require "./log/context"
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
    # Logs key/value data in the Log::Context under the 'local' leu
    #
    # ```crystal
    # Log.{{ method.id }} ->{ {path: "/comments", status: 200 }}
    # ```
    #
    # You can also pass an exception:
    #
    # ```crystal
    # Log.{{ method.id }}(exception) ->{ { query: "SELECT *" } }
    # ```
    def {{method.id}}(exception : Exception?, proc : Proc)
      return unless backend = @backend
      severity = Severity.new({{severity}})
      return unless level <= severity

      proc_result = proc.call

      Log.with_context do
        Log.context.set(local: proc_result)
        {{method.id}}(exception: exception) { "" }
      end
    end

    # :nodoc:
    def {{method.id}}(proc : Proc)
      {{ method.id }}(exception: nil, proc: proc)
    end
  {% end %}
end
