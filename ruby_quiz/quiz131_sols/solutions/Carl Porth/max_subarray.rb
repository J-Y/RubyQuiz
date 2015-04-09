#!/usr/bin/env ruby

require "rubygems"
require "facets"
require "enumerable/each_unique_pair"
require "enumerable/sum"

class Array
  # all contiguous subarrays
  def sub_arrays
    [*0..self.size].to_enum(:each_unique_pair).map { |a,b| self[a..b-1] }
  end
end

array = [-1, 2, 5, -1, 3, -2, 1]

# I find this easy on the eyes
array.sub_arrays.max { |a,b| a.sum <=> b.sum } # => [2, 5, -1, 3]

# but if you didn't want to recompute the sums you could do this
array.sub_arrays.map { |a| [a.sum,a] }.max.last # => [2, 5, -1, 3]
