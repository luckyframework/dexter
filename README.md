# Dexter

A library for logging data and formatting it however you need

* 100% compatible with buil-in Crystal logger
* Adds additional methods for logging data instead of strings
* Custom formatters to log data any way you want

Included is a `JsonLogFormatter`, but you can create your own formatter to format
and output the data however you want.

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

# We're using 'info' but you can do this for 'debug', 'warn', 'error' as well.
logger.info(foo: "bar") # Logs timestamp, severity and {foo: "bar"} as JSON
logger.info("My message) # Logs timestamp, severity and {message: "My message"} as JSON
```

## Contributing

1. Fork it (<https://github.com/luckyframework/dexter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul Smith](https://github.com/paulcsmith) - creator and maintainer
