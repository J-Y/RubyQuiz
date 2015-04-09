require 'trampoline'
class Logger
   def initialize(prefix)
      puts 'Constructing Logger...'
      @prefix = prefix
   end

   def Logger.make(prefix)
      Logger.new(prefix)
   end

   def log(msg)
      puts "#{@prefix}: #{msg}"
   end
end

puts "start"
errors = Trampoline::Bounce.new(Logger, 'ERROR')
puts "made bouncer, about to log message"
errors.log('Hello, world!')
puts "about to log second message"
errors.log('Goodbye, world!')
puts "message logged"

# This is really the same, but eventually calls Logger.make to construct.
puts "start"
warns = Trampoline::Bounce.make(Logger, 'WARNING')
puts "made bouncer, about to log message"
warns.log('Hello, world!')
puts "about to log second message"
warns.log('Goodbye, world!')
puts "message logged"
