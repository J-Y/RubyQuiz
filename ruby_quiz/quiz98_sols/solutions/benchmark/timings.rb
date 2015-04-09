#!/usr/bin/env ruby -w

require "sorted_array"  # Daniel's PriorityQueue
require "heap"          # pure Ruby Heap, from Ruby Quiz #40
require "benchmark"

DATA = Array.new(5_000) { rand(5_000) }.freeze
Benchmark.bmbm(10) do |results|
  results.report("sorted_array:") do
    queue = PriorityQueue.new
    DATA.each { |n| queue.add(n, n) }
    queue.next until queue.empty?
  end
  results.report("ruby_heap:") do
    queue = Heap.new
    DATA.each { |n| queue.insert(n) }
    queue.extract until queue.empty?
  end
end
# >> Rehearsal -------------------------------------------------
# >> sorted_array:  33.950000   0.020000  33.970000 ( 33.972859)
# >> ruby_heap:      0.450000   0.000000   0.450000 (  0.449776)
# >> --------------------------------------- total: 34.420000sec
# >> 
# >>                     user     system      total        real
# >> sorted_array:  33.990000   0.010000  34.000000 ( 34.016562)
# >> ruby_heap:      0.440000   0.000000   0.440000 (  0.437217)
