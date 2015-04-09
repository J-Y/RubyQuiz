#! /usr/bin/ruby
# Quiz 138 - Ruben Medellin

# Will find cycles on a deterministic action
# (that is, applying one defined action to an object, it will always
# produce the same result)
def find_cycles(initial, action, times, output)

	collector = []

	collector << initial
	iteration = initial

	1.upto(times) do |i|
		print "#{i}: " if output
		iteration = action[iteration]
		if collector.include? iteration
			puts "Found cycle at #{x = collector.index(iteration)} -- #{i}",
						iteration,
						"cycle length is #{i - x}"
			return
		end
		collector << iteration
		puts iteration if output
		puts if output
	end
	puts "No cycles found for \"#{initial}\" in #{times} iterations"
end

require 'number_names'

if __FILE__ == $0

	require 'optparse'

	options = {}
	OptionParser.new do |opts|

		opts.banner = "Usage: ruby quiz138 [WORDS]+ [options]"

		opts.on("-t", "--times [INTEGER]") {|times| options[:times] = times.to_i }
		opts.on("-o", "--output") { options[:output] = true }
		opts.on_tail("-h", "--help", "Show this message") do
      			puts opts
			exit
    		end

	end.parse!

	text = ARGV.join(' ')
	ALPHABET = [*'a'..'z']
	find_cycles(	text,
			proc do |text|
				ALPHABET.inject('') do |str, letter|
					x = text.count(letter)
					str + (x == 0 ? '' : "#{x.name} #{letter} ")
				end.strip
			end,
			options[:times] || 1000, options[:output])
end

