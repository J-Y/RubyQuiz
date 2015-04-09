#!/usr/bin/env ruby -w

require "sorted_array"  # Daniel's PriorityQueue
require "heap"          # pure Ruby Heap, from Ruby Quiz #40

DATA = Array.new(5_000) { rand(5_000) }.freeze

queue1, queue2 = PriorityQueue.new, Heap.new
DATA.each do |n|
  queue1.add(n, n)
  queue2.insert(n)
end

until queue1.empty?
  raise "Mismatch!" unless queue1.next == queue2.extract
end

puts "All values matched."