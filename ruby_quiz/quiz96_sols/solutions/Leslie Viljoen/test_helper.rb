require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'helper'

class TestArray < Test::Unit::TestCase
 def test_any
   a = [1, 2, 3, 4, 5]

   outOfBounds = false
   100.times do
     any = a.any
     outOfBounds = true if !(a.include? any)
   end
   assert(!outOfBounds, "Item returned is not in the array")
 end

 def test_any_coverage
   a = [1, 2, 3, 4, 5]

   coverage = {}
   count = 0
   loop do
     any = a.any
     coverage[any] = 0
     break if coverage.keys.length == 5

     count += 1
     if count > 100
       assert(false, message="Possible random number problem, coverage not achieved after 100 iterations")
       return
     end
   end

   assert(coverage.keys.length == 5)
   assert(coverage.keys.inject{|a, b| a > b ? a : b} == 5) #max = 5
   assert(coverage.keys.inject{|a, b| a < b ? a : b} == 1) #min = 1
 end

 def test_any_variance
   a = [1, 2]
   any1 = a.any
   any2 = a.any

   assert(any2 == 2) if any1 == 1
   assert(any2 == 1) if any1 == 2

   assert(a.include?(a.any))
 end
end
