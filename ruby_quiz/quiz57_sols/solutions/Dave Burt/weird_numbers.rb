class Fixnum
    def divisors
        (1..self).select {|i| self % i == 0 }
    end
end
module Enumerable
    def sum
        inject(0) {|m, o| m + o }
    end
end
class Array
    def subsets
        ArraySubsetList.new(self)
    end
end
class ArraySubsetList
    def initialize(array)
        @array = array
    end
    def [](index)
        return nil unless (0...size) === index
        ret = []
        @array.size.times {|i| ret << @array[i] if index[i] == 1 }
        ret
    end
    def each
        size.times {|bits| yield self[bits] }
    end
    include Enumerable
    def size
        1 << @array.size
    end
    alias length size
end
def wierd_numbers_up_to(max)
    ret = []
    for n in 1..max
        # A weird number is defined as a number, n, such that the sum of all its divisors
        # (excluding n itself) is greater than n, but no subset of its divisors sums up to
        # exactly n.
        divs = n.divisors
        divs.delete i
        if divs.sum > i &&
           divs.subsets.select {|subset| subset.sum == i }.empty?
            ret << i
            yield i if block_given?
        end
    end
    ret
end
if $0 == __FILE__
    if ARGV.size == 1 && (ARGV[0].to_i rescue 0) > 0
        wierd_numbers_up_to(ARGV[0].to_i) {|n| puts n }
    else
        puts "usage: #$0 n\n  Find all weird numbers less than n"
    end
end
