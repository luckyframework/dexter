# Dexter

A library for logging data and formatting it however you need

* 99% compatible with built-in Crystal logger ([see caveat](#compatibility-caveat)).
* Adds additional methods for logging data instead of strings
* Custom formatters to log data any way you want

Included is a `JsonLogFormatter`, but you can create your own formatter to format
and output the data however you want. For example,
[Lucky](https://luckyframework.org) has a `PrettyLogFormatter` that formats data
in a human readable format during development, and uses the `JsonLogFormatter`
in production.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     dexter:
       github: luckyframework/dexter
   ```

2. Run `shards install`

## Usage

```crystal
require "dexter"

logger = Dexter::Logger.new(
  io: STDOUT,
  level: Logger::Severity::INFO,
  log_formatter: Dexter::Formatters::JsonLogFormatter.new
)

# These examples use 'info' but you can use 'debug', 'warn', and 'error' as well.
#
# Logs timestamp, severity and {foo: "bar"} as JSON
logger.info(foo: "bar")

# Compatible with built-in Crystal logger for logging string messages
#
# Logs timestamp, severity and {message: "My message"} as JSON
logger.info("My message")

# Or pass the severity in:
logger.log(severity: Logger::Severity::DEBUG, foo: "bar")
```

## Compatibility Caveat

Dexter will work everywhere the built-in Crystal `Logger` works. The only
caveat is that Dexter ignores the `formatter` used by `Logger` because Dexter
uses its own formatter that is incompatible with Crystal's `Logger`.

So what does this mean? **In practice, it is a non-issue**. If you are using
Dexter it is because you want the Dexter formatting, not the Crystal formatter.

For example, in this code the formatter will not be used, and Dexter will print a warning:

```crystal
logger = Dexter::Logger.new(STDOUT)

# This will print a warning message and the formatter will not be used
#
# Usually people do this on accident or because the app was using the default
# Crystal Logger and is being upgraded to Dexter.
logger.formatter = ::Logger::Formatter.new do |severity, datetime, progname, message, io|
  "This will not ever run"
end
```

The fix is simple, use a Dexter formatter and set it with `log_formatter=` instead:

```crystal
logger = Dexter::Logger.new(STDOUT)
# Use 'log_formatter=' as documented in the README
logger.log_formatter = Dexter::Formatters::JsonLogFormatter
```

> **Q:** Why is 'formatter=' defined in Dexter if Dexter ignores it?

> **A** For Dexter to be usable in libraries that accept a Crystal `Logger`,
> Dexter must have all the same methods as `Logger`.

## Contributing

1. Fork it (<https://github.com/luckyframework/dexter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul Smith](https://github.com/paulcsmith) - creator and maintainer
