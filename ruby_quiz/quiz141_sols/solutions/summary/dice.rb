#!/usr/bin/env ruby -wKU

MODE = if ARGV.first =~ /-([sv])/
  ARGV.shift
  $1
end

unless ARGV.size == 2
  abort "Usage: #{File.basename($PROGRAM_NAME)} [-s|-v] NUM_DICE MIN_FIVES"
end
NUM_DICE, MIN_FIVES = ARGV.map { |n| Integer(n) }

POSSIBLE_OUTCOMES  = 6 ** NUM_DICE
desirable_outcomes = 0

POSSIBLE_OUTCOMES.times do |i|
  outcome = i.to_s(6).rjust(NUM_DICE, "0")
  if desirable = outcome.count("4") >= MIN_FIVES
    desirable_outcomes += 1
  end
  if MODE == "v" or (MODE == "s" and (i % 50_000).zero?)
    puts "%#{NUM_DICE}d [%s]#{' <==' if desirable}" %
         [i + 1, outcome.tr("0-5", "1-6").gsub(/(\d)(\d)/, '\1,\2')]
  end
end

puts if MODE
puts "Number of desirable outcomes is #{desirable_outcomes}"
puts "Number of possible outcomes is #{POSSIBLE_OUTCOMES}"
puts
puts "Probability is #{desirable_outcomes / POSSIBLE_OUTCOMES.to_f}"
