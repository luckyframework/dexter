require "../spec_helper"

describe Dexter::Formatters::JsonLogFormatter do
  it "formats the data as JSON" do
    data = {
      my_data: "is great!",
    }
    io = IO::Memory.new

    Dexter::Formatters::JsonLogFormatter.new(
      severity: Logger::Severity::INFO,
      timestamp: timestamp,
      progname: "",
      io: io
    ).format(data)

    io.to_s.chomp.should eq(
      {severity: "INFO", timestamp: timestamp, my_data: "is great!"}.to_json
    )
  end
end

private def timestamp
  Time.utc(2016, 2, 15)
end
