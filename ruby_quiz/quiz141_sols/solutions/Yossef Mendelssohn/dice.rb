#!/usr/bin/env ruby

require 'optparse'

verbose = false
check   = false

dice   = 1
wanted = 1

SIDES = 6
CHECK_FREQUENCY = 50000

OptionParser.new do |opts|
  opts.on('-d', '--dice [DICE]', Integer, 'The number of dice to roll') do |dice_opt|
    dice = dice_opt.to_i
  end
  opts.on('-w', '--wanted [WANTED]', Integer, 'The number of 5s to check for') do |wanted_opt|
    wanted = wanted_opt.to_i
  end
  opts.on('-c', '--check', 'Turn on check mode') do |check_opt|
    check   = check_opt
    verbose = false
  end
  opts.on('-v', '--verbose', 'Turn on verbose mode') do |verbose_opt|
    verbose = verbose_opt
    check   = false
  end
  opts.parse!(ARGV)
end

CONFIG = {
  :dice    => dice,
  :wanted  => wanted,
  :verbose => verbose,
  :check   => check
}

if CONFIG[:verbose] or CONFIG[:check]
  puts 'Outcomes:'
  puts
end

@wanted   = 0
@outcomes = SIDES ** dice
@number   = 0

def generate_outcomes(num_dice, *previous_rolls)
  if num_dice == 0
    num_wanted = previous_rolls.select { |x|  x == 5 }.length
    wanted = num_wanted >= CONFIG[:wanted]
    if wanted
      @wanted += 1
    end
    display = CONFIG[:verbose] || (CONFIG[:check] && (@number % CHECK_FREQUENCY).zero?)
    if display
      print " %#{@outcomes.to_s.length}d" % (@number + 1)
      print ' '
      print previous_rolls.inspect
      print ' <=' if wanted
      puts
    end
    @number += 1
  elsif num_dice > 0
    1.upto(SIDES) do |x|
      generate_outcomes(num_dice - 1, *(previous_rolls + [x]))
    end
  end
end


generate_outcomes(dice)

puts if CONFIG[:verbose] or CONFIG[:check]
puts "Possible outcomes: #{@outcomes}"
puts "Desired outcomes: #{@wanted}"
puts "Probability: #{@wanted.to_f/@outcomes.to_f}"
