#!/usr/bin/env ruby -rubygems

# integer_to_english.rb -> http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/135449
%w(facet/string/chars facet/enumerable/injecting facet/symbol/to_proc integer_to_english).each(&method(:require))

class String
  def letter_histogram
    upcase.gsub(/[^A-Z]/,'').chars.injecting(Hash.new(0)){|h, l| h[l] += 1}
  end

  def count_and_say
    letter_histogram.sort_by{|l,n| l}.map{|(l, n)| "#{n.to_english.upcase} #{l}"}.join(" ")
  end
end

class Object
  def detect_cycles
    ary = [self]
    loop do
      val = yield(ary.last)
      if ary.include? val
        return [ary.index(val)+1, ary.length - ary.index(val)]
      end
      ary << val
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  tail, cycle_length = ARGV.join.detect_cycles(&:count_and_say)
  puts "Took #{tail} cycles to enter a cycle of length #{cycle_length}"
end
