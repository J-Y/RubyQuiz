#!/usr/bin/env ruby -wKU

class PossibleRolls
  include Enumerable
  
  def initialize(dice=1, sides=(1..6))
    @dice, @sides = dice, sides
  end
  
  def each(&block)
    each_roll(@dice, &block)
  end
  
protected
  
  def each_roll(dice, rolls=[], &block)
    if dice.zero?
      yield(rolls)
    else
      @sides.each do |roll|
        each_roll(dice-1, [roll]+rolls, &block)
      end
    end
  end
  
end

if $PROGRAM_NAME == __FILE__
  require "optparse"
  
  options = {:output => nil}
  
  ARGV.options do |opts|
    opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] DICE FIVES"
    
    opts.separator ""
    opts.separator "Specific Options:"
    
    opts.on( "-v", "--verbose", "Output all combinations" ) do
      options[:output] = :verbose
    end
    
    opts.on( "-s", "--sample", "Sample every 50,000 times" ) do
      options[:output] = :sample
    end
    
    opts.separator "Common Options:"
    
    opts.on( "-h", "--help", "Show this message." ) do
      puts opts
      exit
    end
    
    begin
      opts.parse!
      options[:dice]  = Integer(ARGV.shift)
      options[:fives] = Integer(ARGV.shift)
    rescue
      puts opts
      exit
    end
  end
  
  def print_roll(roll,n,desirable)
    puts "#{n.to_s.rjust(10)}   [#{roll.join(',')}]#{'  <==' if desirable}"
  end
  
  desirables, possibles = 0, 0
  
  PossibleRolls.new(options[:dice]).each_with_index do |roll, index|
    desirable = roll.select { |die| die == 5 }.size >= options[:fives]
    
    desirables += 1 if desirable
    possibles += 1
    
    case options[:output]
    when :verbose
      print_roll(roll, index+1, desirable)
    when :sample
      print_roll(roll, index+1, desirable) if (index % 50_000).zero?
    end
  end
  
  puts
  puts "Number of desirable outcomes is #{desirables}"
  puts "Number of possible outcomes is #{possibles}"
  puts
  puts "Probability is #{desirables.to_f / possibles}"
end