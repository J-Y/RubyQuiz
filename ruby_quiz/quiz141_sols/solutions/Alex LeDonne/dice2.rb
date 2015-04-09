# Math.nCr(n,r) borrowed from Brian Candler's
# post in ruby_talk

def Math.nCr(n,r)
 a, b = r, n-r
 a, b = b, a if a < b  # a is the larger
 numer = (a+1..n).inject(1) { |t,v| t*v }  # n!/r!
 denom = (2..b).inject(1) { |t,v| t*v }    # (n-r)!
 numer/denom
end

class DiceAtLeastFive
    def self.int_to_roll( serial, numdice )
#        good for reality, too slow for a quiz - #pow is expensive.
#        raise if serial >= 6**numdice
        serial.to_s(6).rjust(numdice,"0").split(//).map!{|ele| ele.to_i + 1 }.reverse
    end

    def self.total_rolls(numdice)
        6**numdice
    end

    def self.desirable(numdice, min_fives)
        (min_fives..numdice).inject(0) { |tot, val| tot + (Math.nCr(numdice,val) * 5**(numdice-val)) }
    end

end


require 'optparse'
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:iter_step] = 1
  end
  opts.on("-s", "--sample", "Run in sample mode") do |s|
    options[:iter_step] = 50000
  end
end.parse!

total_dice, at_least_5 = Integer(ARGV[0]), Integer(ARGV[1])
des=DiceAtLeastFive.desirable(total_dice,at_least_5)
tot=DiceAtLeastFive.total_rolls(total_dice)

if options[:iter_step]
    (0..tot-1).step(options[:iter_step]) { |serial|
        marker = ""
        roll = DiceAtLeastFive.int_to_roll(serial, total_dice)
        if roll.select{|die| die==5}.length >= at_least_5
            marker = " <=="
        end
        puts "#{serial+1}  #{roll.inspect} #{marker}"
    }
end

puts "\nNumber of desirable outcomes is #{des}"
puts "Number of possible outcomes is #{tot}"
puts "\nProbability is %16.16f" %(des.to_f/tot)
