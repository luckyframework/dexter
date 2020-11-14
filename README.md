# Dexter

[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fluckyframework.github.io%2Fdexter%2F)](https://luckyframework.github.io/dexter)

Extensions to Crystal's `Log` class.

* 100% compatible with built-in Crystal's [`Log`](https://crystal-lang.org/api/latest/Log.html)
* Adds methods for easily logging key/value data
* Built-in `Dexter::JSONLogFormatter` for formatting Logs as JSON
* Helper class for making log formatting simpler and more flexible
* Simpler configuration with helpful compile-time guarantees
* Helper methods for testing log output more easily

And everything is optional so if you only want the JSON formatter you can just use that.
Dexter does not break the existing `Log` and is a *very* small library.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     dexter:
       github: luckyframework/dexter
       version: ~> 0.3
   ```

2. Run `shards install`

## Getting started example

```crystal
require "dexter"

backend = Log::IOBackend.new
backend.formatter = Dexter::JSONLogFormatter.proc
# Equivalent to: Log.builder.bind "*", :info, backend
Log.dexter.configure(:info, backend)

# These examples use 'info' but you can use 'debug', 'warn', and 'error' as well.
#
# Logs timestamp, severity and {foo: "bar"} as JSON
Log.dexter.info { {foo: "bar"} }

# You can pass an exception *and* key/value data
Log.dexter.error(exception: my_exception) { {foo: "bar"} }

# Fully compatible with built-in Crystal Log
#
# Logs timestamp, severity and {message: "My message"} as JSON
Log.info { "My message" }
```

## Type-safe Log configuration

Use `{LogClass}.dexter.configure to configure `{LogClass}` and its child logs

Rather than pass a string `source` to `Log.builder.bind` you can configure a
log using its class. This is a type-safe and simpler alternative to using
`Log.builder.bind`.

## Examples:

> Note: the backend can be left off and it will use the `{LogClass}`'s
> existing backend or a new `Log::IOBackend`

```crystal
# Configure all logs.
# Similar to `Log.builder.bind "*"`
Log.dexter.configure(:info, backend)

# Configure Avram::Log and all child logs
# Similar to `Log.builder.bind "avram.*"
Avram::Log.dexter.configure(:warn)

# Can further customize child Logs
Avram::QueryLog.dexter.configure(:none)
Avram::FailedQueryLog.dexter.configure(:info, SomeOtherBackend.new)
```

`{LogClass}.dexter.configure` sets all child logs to the given
level/backend . If you want to configure a Log and leave its children alone
it is best to set the `level` or `backend` directly:

```crystal
MyShard::Log.level = :error
MyShard::Log.backend = MyCustomBackend.new
```

## Test helpers

This will temporarily configure the given log with a `Log::IOBackend`
with an `IO::Memory` that is yielded. The log level is also
temporarily set to `:debug` to log all messages

```crystal
MyShard::Log.dexter.temp_config do |log_io|
  MyShard::Log.info { "log me" }
  log_io.to_s.should contain("log me")
end
```

There are more options for changing the level, passing your own IO, etc. See
the [documentation](https://github.com/luckyframework/dexter/blob/6144739a6d1a2d0f64d95a89086495c17cafe7eb/src/dexter/log.cr#L80) for more details

## Built-in formatters

Dexter works with *any* `Log::Formatter`, but has a JSON formatter built-in
that works especially well.

* Logs exceptions in an easily parseable format
```json
{
  "exception": { "class": "RuntimeError", "message": "Something broke", backtrace: ["line_of_code.cr:123"] }
}
```
* Puts string message in a `message` key that comes first so you can find it easily
* JSON works great for searching logs with many SaaS logging services


## Create your own formatter

Included is a `Dexter::JSONLogFormatter`, but you can create your own formatter to format
and output log data however you want. For example,
[Lucky](https://luckyframework.org) has a `PrettyLogFormatter` that formats data
in a human readable format during development, and uses the `JSONLogFormatter`
in production.

See an example formatter in [Dexter::JSONLogFormatter](https://github.com/luckyframework/dexter/blob/master/src/dexter/json_log_formatter.cr)

## Contributing

1. Fork it (<https://github.com/luckyframework/dexter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul Smith](https://github.com/paulcsmith) - creator and maintainer
