require 'happy'
require 'benchmark'

Benchmark.bmbm(10) do |b|
	b.report("simple:") { 10000.times { |n| HappyClass.happy_simple(n) } }
	b.report("smarter:") { 10000.times { |n| HappyClass.happy_smarter(n) } }
	b.report("cached:") { 10000.times { |n| HappyClass.happy_cached(n) } }
end