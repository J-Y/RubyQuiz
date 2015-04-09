#!/usr/bin/env ruby
open("practical-file-system-design.txt") do |f|
   FILEDATA=f.read
end

open("words_en.txt") do |f|
   DICTIONARY=f.readlines.map{|x| x.chomp}
end

require 'benchmark'
include Benchmark
#the following files contain various implementations, renamed so as not to
#conflict with each other
require 'trie'
require 'finedm'

TESTCLASSES={"Ken Bloom" => KenDictionaryMatcher,
  "Edwin Fine" => FineDictionaryMatcher}

bm(TESTCLASSES.keys.collect{|x| x.length}.max + 8) do |benchmarker|
   matcher=nil
   TESTCLASSES.each do |name,klass|
      benchmarker.report("#{name} -- fill") do
	 matcher=klass.new
	 DICTIONARY.each {|x| matcher << x}
      end
      benchmarker.report("#{name} -- test") do
	 matcher.scan(FILEDATA){}
      end
   end
end
