require "spec"
require "../src/dexter"

struct Log::Entry
  # So that the timestamp can be overridden in test
  property timestamp
end

Spec.before_each do
  ::Log.builder.clear
end

class Log
  def reload
    for(source)
  end
end
