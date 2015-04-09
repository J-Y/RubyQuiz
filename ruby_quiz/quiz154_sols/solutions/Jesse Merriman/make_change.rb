#!/usr/bin/env ruby
# Ruby Quiz 154: Making Change
# Score-function-general solution.
# Jesse Merriman

Infinity = 1.0 / 0

module Enumerable
  def sum; inject { |sum, x| sum + x }; end
end

LeastCoins = lambda { |sol| - sol.values.sum }
MostCoins  = lambda { |sol| sol.values.sum }
Variety    = lambda { |sol| sol.values.select { |v| v > 0 }.size }

def make_change amount, coins = [25, 10, 5, 1], scorer = LeastCoins
  pick = coins.first
  others = coins[1..-1]

  if coins.size == 1
    return (amount % pick).zero? ? {pick => amount / pick} : nil
  end

  best_so_far = {:sol => nil, :score => -Infinity}

  (0 .. amount / pick).each do |count|
    sol = make_change amount - count * pick, others, scorer

    if not sol.nil?
      sol[pick] = count
      s = scorer[sol]
      if s > best_so_far[:score]
        best_so_far[:sol] = sol
        best_so_far[:score] = s
      end
    end
  end

  best_so_far[:sol]
end

if $0 == __FILE__
  amount = ARGV.first.to_i
  coins = ARGV[1..-2].map { |x| x.to_i }
  scorer = case ARGV.last
    when /most/i    then MostCoins
    when /variety/i then Variety
    else LeastCoins
  end

  sol = make_change amount, coins, scorer
  if sol.nil?
    puts 'No solution could be found.'
  else
    sol.each do |coin, count|
      puts "#{count} of #{coin}-coins"
    end
    puts "#{sol.values.sum} total"
    #sol.to_a.map { |x| [x.first] * x.last }.flatten
  end
end

