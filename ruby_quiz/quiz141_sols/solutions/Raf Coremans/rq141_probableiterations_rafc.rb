#!/usr/bin/ruby -w

# rq141_probableiterations_rafc.rb
# Solution to http://rubyquiz.com/quiz141.html
# By Raf Coremans
#
# Usage examples:
# ./rq141_probableiterations_rafc.rb 8 3
# ./rq141_probableiterations_rafc.rb -d=d10,2d6,d20 -s=888 2
# ./rq141_probableiterations_rafc.rb


class Integer

  def dice( sides = 6)
    [1..sides] * self
  end

  def method_missing( method_name, *args)
    if args.empty? && method_name.to_s =~ /\Ad(\d+)\Z/
      dice( $1.to_i)
    else
      super
    end
  end 

end


class Array

  def each_throw( check_die = lambda{}, undo_check_die = lambda{}, throw_so_far = [], &blk)
    if empty?
      yield throw_so_far
    else
      die = shift
      die.each do |throw_of_one_die|
        throw_so_far.push( throw_of_one_die)
        check_die.call( throw_of_one_die)
        each_throw( check_die, undo_check_die, throw_so_far, &blk)
        undo_check_die.call( throw_of_one_die)
        throw_so_far.pop
      end
      unshift( die)
    end
  end

end


def parse_options( args = ARGV)
  options = {}

  options[:verbose?] = args.include?( '-v')

  if args.any?{ |opt| opt =~ /\A-s(=(\d+))?/}
    options[:sample?] = true
    options[:sample_freq] = $2 ? $2.to_i : 50_000
  end

  if args.any?{ |opt| opt =~ /\A-d(=(.+))?/}
    dice = $1.scan( /(\d+)?(d(\d+))/).inject( []) do |dice, die|
      dice << (die[0] ? die[0].to_i : 1).send( die[1])
    end.flatten
  end

  args.delete_if{ |opt| opt =~ /\A-/}
  
  dice = args.shift.to_i.dice unless dice

  number_of_fives_wanted = args.shift.to_i

  [options, dice, number_of_fives_wanted]
end


def run( dice, check_die = lambda{}, undo_check_die = lambda{}, check_throw = lambda{}, options = {})
  possible_outcomes = 0
  desirable_outcomes = 0

  dice.each_throw( check_die, undo_check_die) do |throw|
    outcome_is_desirable = check_throw.call( )

    possible_outcomes += 1
    desirable_outcomes += 1 if outcome_is_desirable

    if options[:verbose?] || (options[:sample?] && 1 == possible_outcomes.modulo( options[:sample_freq]))
      puts "#{possible_outcomes} #{throw.inspect}#{' <==' if outcome_is_desirable}"
    end
  end

  puts
  puts "Number of desirable outcomes is #{desirable_outcomes}"
  puts "Number of possible outcomes is #{possible_outcomes}"
  puts
  puts "Probability is #{desirable_outcomes.to_f / possible_outcomes}"
end
  

def demo
  puts '5 usual dice; # of sixes greater than # of ones:'

  number_of_ones = 0
  number_of_sixes = 0

  check_die = lambda do |throw_of_one_die|
    number_of_ones += 1 if 1 == throw_of_one_die
    number_of_sixes += 1 if 6 == throw_of_one_die
  end

  undo_check_die = lambda do |throw_of_one_die|
    number_of_ones -= 1 if 1 == throw_of_one_die
    number_of_sixes -= 1 if 6 == throw_of_one_die
  end

  check_throw = lambda do
    number_of_sixes > number_of_ones
  end

  run( 5.dice, check_die, undo_check_die, check_throw, {:sample? => true, :sample_freq => 500})


  puts
  puts '======================================================================================'
  puts
  puts '3 tetrahedra (d4); sum of evens smaller than sum of odds:'

  sum_of_odds = 0
  sum_of_evens = 0

  check_die = lambda do |throw_of_one_die|
    if 0 == throw_of_one_die.modulo( 2)
      sum_of_evens += throw_of_one_die
    else
      sum_of_odds += throw_of_one_die
    end
  end

  undo_check_die = lambda do |throw_of_one_die|
    if 0 == throw_of_one_die.modulo( 2)
      sum_of_evens -= throw_of_one_die
    else
      sum_of_odds -= throw_of_one_die
    end
  end

  check_throw = lambda do
    sum_of_evens < sum_of_odds
  end

  run( 3.d4, check_die, undo_check_die, check_throw, {:verbose? => true})


  puts
  puts '======================================================================================'
  puts
  puts '3 usual dice and 2 dodecahedra (d12): product greater than 1000'

  product = 1

  check_die = lambda do |throw_of_one_die|
    product *= throw_of_one_die
  end

  undo_check_die = lambda do |throw_of_one_die|
    product /= throw_of_one_die
  end

  check_throw = lambda do
    product > 1000
  end

  run( 3.d6 + 2.d12, check_die, undo_check_die, check_throw, {:sample? => true, :sample_freq => 2500})
end


### Main: ###

if ARGV.empty?
  demo
else
  options, dice, number_of_fives_wanted = parse_options

  number_of_fives = 0

  check_die = lambda do |throw_of_one_die|
    number_of_fives += 1 if 5 == throw_of_one_die
  end

  undo_check_die = lambda do |throw_of_one_die|
    number_of_fives -= 1 if 5 == throw_of_one_die
  end

  check_throw = lambda do
    number_of_fives >= number_of_fives_wanted
  end

  run( dice, check_die, undo_check_die, check_throw, options)
end