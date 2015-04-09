require 'optparse'
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:v] = 1
  end
  opts.on("-s", "--sample", "Run in sample mode") do |s|
    options[:s] = 1
  end
end.parse!

total_dice, at_least_5 = Integer(ARGV[0]), Integer(ARGV[1])
des=0
tot=6**total_dice
roll = Array.new(total_dice){1}
roll[0] = 0

(0..tot-1).each { |serial|
    marker = ""
    roll[0]+=1
    (0..total_dice-1).each do |idx|
        if roll[idx]==7
            roll[idx]=1
            roll[idx+1]+=1
        else
            break
        end
    end
    if roll.select{|die| die==5}.length >= at_least_5
        marker = " <=="
        des += 1
    end
    if options[:v] || (options[:s] && (serial % 50000)==0 )
        puts "#{serial+1}  #{roll.inspect} #{marker}"
    end
}

puts "\nNumber of desirable outcomes is #{des}"
puts "Number of possible outcomes is #{tot}"
puts "\nProbability is %16.16f" %(des.to_f/tot)
