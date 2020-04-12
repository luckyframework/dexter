require "spec"
require "../src/dexter"

struct Log::Entry
  # So that the timestamp can be overridden in test
  property timestamp
end
