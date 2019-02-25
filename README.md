# Dexter

A library for logging data and formatting it however you need

* 100% compatible with built-in Crystal logger
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

## Contributing

1. Fork it (<https://github.com/luckyframework/dexter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul Smith](https://github.com/paulcsmith) - creator and maintainer
