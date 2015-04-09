#!/usr/local/bin/ruby -w

require "curry"

scale = lambda { |size, object| object * size }

puts "3 scaleded to a size of 10 is #{scale[10, 3]}."
puts

# curry some functions
double = scale.curry(2)
triple = scale.curry(3)
halve  = scale.curry(0.5)

puts "4 doubled is #{double[4]}."
puts "1 tripled is #{triple[1]}."
puts "Half of 10 is #{halve[10]}."

puts

scale = lambda { |object, size| object * size }

puts "3 scaleded to a size of 10 is #{scale[3, 10]}."
puts

# we can leave "holes" in the argument list
double = scale.curry(Curry::HOLE, 2)
triple = scale.curry(Curry::HOLE, 3)
halve  = scale.curry(Curry::HOLE, 0.5)

puts "4 doubled is #{double[4]}."
puts "1 tripled is #{triple[1]}."
puts "Half of 10 is #{halve[10]}."

puts

class LazySpice < Curry::SpiceArg
  def initialize( &promise )
    super("LAZYSPICE")
    
    @promise = promise
  end

  def spice_arg( args )
    [@promise.call]
  end
end

logger = lambda do |time, message|
  puts "[#{time.strftime('%I:%M:%S %p %m/%d/%y')}] #{message}"
end

log_now = logger.curry(LazySpice.new { Time.now })

log_now["First Message."]
sleep 3
log_now["Second Message."]
