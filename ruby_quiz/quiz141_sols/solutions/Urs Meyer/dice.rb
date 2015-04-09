#!/usr/bin/ruby
#
# 141 probable iterations

require 'optparse'

def generate(n, m, &blk)
    if n == 0
        yield []
    else
        1.upto(m) { |i|
            generate(n-1, m) { |result| yield result + [i] }
        }
    end
end

options = {}
OptionParser.new do |opts|
    opts.on("-v", "--verbose", "verbose") { |v| options[:verbose] = v }
    opts.on("-s", "--samples", "show samples") { |v| options[:samples] = v }
end.parse!

if ARGV.length != 2
    STDERR.puts "usage: #{$0} [-s|-v] n k"
    exit
end

n = ARGV[0].to_i
k = ARGV[1].to_i

possible = desired = 0

# generate all possible solutions of throwing n dice

generate(n, 6) { |soln|
    possible += 1

    # selection criteria: at least k fives
    found = soln.select{ |i| i==5 }.size >= k

    desired += 1 if found
    puts "%10d" % possible + "   " + soln.inspect + (found ? "  <==" : "") \
        if ( options[:verbose] || options[:samples] && possible % 50000 == 1)
}

puts
puts "Number of possible outcomes is #{possible}"
puts "Number of desired outcomes is #{desired}"
puts
puts "Probability is #{desired.to_f/possible}"
