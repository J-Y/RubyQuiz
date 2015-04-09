#!/usr/local/bin/ruby -w

# time_trial.rb
#
#  Created by James Edward Gray II on 2005-08-31.
#  Copyright 2005 Gray Productions. All rights reserved.

dictionary_file = "/usr/share/dict/words"
if ARGV.size >= 2 and ARGV.first == "-d"
	ARGV.shift
	dictionary_file = ARGV.shift
end

unless ARGV.size == 2 and ARGV.first != ARGV.last and
       ARGV.first.length == ARGV.last.length
	puts "Usage:  #{File.basename($0)} [-d DICTIONARY] START_WORD END_WORD"
	exit
end
start, finish = ARGV

Dir[File.dirname(__FILE__) + "/*"].each do |dir|
	next if dir =~ /time_trial\.rb/
	
	Dir[dir + "/*chain*"].each do |solution|
		puts
		puts "=== Timing #{solution} ==="

		start_time = Time.now
		system "ruby -I #{dir.gsub(' ', '\ ')} #{solution.gsub(' ', '\ ')} " +
		       "-d #{dictionary_file} #{start} #{finish}"

		puts "=== #{solution}:  #{Time.now - start_time} seconds ==="
	end
end
puts
