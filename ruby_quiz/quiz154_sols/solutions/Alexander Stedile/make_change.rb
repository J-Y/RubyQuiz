#!/usr/bin/ruby

# Usage: make_change.rb <amount> [<coins_separated_by_commas>]

def make_change(amount, coins = [25, 10, 5, 1])
 coins = coins.sort.reverse
 solution_change = nil
 solution_remainder = nil

 until coins.empty?
   remainder = amount
   change = []

   coins.each { |c|
     until remainder < c do
       # Take as many big coins as possible.
       remainder -= c
       change << c
     end
   }

   if solution_change.nil? || change.size < solution_change.size
     solution_change = change # Found first or better solution.
     solution_remainder = remainder
   end

   coins.shift # Try without highest value coin until empty.
 end
 puts "Missing coin: #{solution_remainder}." unless solution_remainder == 0
 solution_change
end

if __FILE__ == $0 then
 if ARGV[1]
   coins = ARGV[1].split(",").collect{ |coin| coin.to_i }
   p make_change(ARGV[0].to_i, coins)
 else
   p make_change(ARGV[0].to_i)
 end
end