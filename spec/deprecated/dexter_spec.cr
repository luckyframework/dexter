require "../spec_helper"

private struct RawFormatter < Dexter::Formatters::BaseLogFormatter
  def format(data) : Nil
    io << data
  end
end

describe Dexter::Logger do
  it "inherits from the Crytal Logger" do
    build_logger.should be_a(::Logger)
  end

  it "ignores the base logger formatter=, but still returns the logging" do
    io = IO::Memory.new
    logger = build_logger(io)
    logger.formatter = "Whatever"

    logger.info("Something")

    io.to_s.chomp.should contain(%(Please use 'log_formatter=' instead))
    io.to_s.chomp.should contain(%({message: "Something"}))
  end

  it "converts string into NamedTuple" do
    io = IO::Memory.new
    logger = build_logger(io)

    logger.info("Something")

    io.to_s.chomp.should eq(%({message: "Something"}))
  end

  it "allows logging key/value data" do
    io = IO::Memory.new
    logger = build_logger(io)

    logger.log(Logger::Severity::INFO, foo: "bar")

    io.to_s.chomp.should eq(%({foo: "bar"}))
  end

  {% for name in ::Logger::Severity.constants %}
    it "logs key/value data for '{{ name.id.downcase }}'" do
      io = IO::Memory.new
      logger = build_logger(io)

      logger.{{ name.id.downcase }}({foo: "bar"})

      io.to_s.chomp.should eq(%({foo: "bar"}))
    end

    it "logs splatted key/value data for '{{ name.id.downcase }}'" do
      io = IO::Memory.new
      logger = build_logger(io)

      # Surrounding {} not required:
      logger.{{ name.id.downcase }}(foo: "bar")

      io.to_s.chomp.should eq(%({foo: "bar"}))
    end
  {% end %}
end

private def build_logger(io = STDOUT)
  Dexter::Logger.new(io, level: Logger::Severity::DEBUG, log_formatter: RawFormatter)
end
