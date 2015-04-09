# alternators.rb
# Ruby Quiz 118: Microwave Numbers

# For "something that produces alternate seconds values" I'm using the word
# "alternator" - it can be any Proc that takes as an argument the number of
# seconds, and returns an Enumerable of "close enough" seconds to try.

require 'set'

Exact = lambda { |seconds| [seconds] }

# Produce an alternator that will return all seconds within the given 
tolerance
# from the target number of seconds (eg, Tolerance[2][10] will return 
(8..12)).
Tolerance = lambda do |tolerance|
  lambda do |seconds|
    ([seconds - tolerance, 0].max..seconds + tolerance)
    # Any way to pass a block to a Proc?
    #([seconds - tolerance, 0].max..seconds + tolerance).each do |sec|
    #  yield(sec)
    #end
  end
end

# Produce a few values close by. This isn't really useful, just an example of
# another alternator.
RandomClose = lambda do |seconds|
  s = Set[seconds]
  (rand(10)+1).times { s << [seconds + rand(21) - 10, 0].max }
  s
end
