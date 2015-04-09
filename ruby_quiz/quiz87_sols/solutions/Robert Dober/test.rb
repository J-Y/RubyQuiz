#!/usr/bin/ruby

require 'sleepy'

sons = []
### Thread #2 will finish easily in 2 seconds
5.times do
	|n|
	sons << Thread.new("thread#" << n.to_s){
		|name|
		sleep( -1 ) if n==2
		# the next line is useful if you do not want the sleep( -2 )
		# to slow down Thread#2 at the beginning.
		###sleep( 1 ) if n==3
		(ARGV.first || "1000").to_i.times do
			|i|
			puts name.dup << ": " << i.to_s
		end
		
	}
end
sons.each { |son| son.join }