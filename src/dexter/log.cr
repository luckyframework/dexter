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

    {% for method, severity in SEVERITY_MAP %}
      # Logs key/value data in the Log::Context under the 'local' leu
      #
      # ```crystal
      # Log.dexter.{{ method.id }} ->{ {path: "/comments", status: 200 }}
      # ```
      #
      # You can also pass an exception:
      #
      # ```crystal
      # Log.dexter.{{ method.id }}(exception) ->{ { query: "SELECT *" } }
      # ```
      def {{method.id}}(*, exception : Exception? = nil)
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
