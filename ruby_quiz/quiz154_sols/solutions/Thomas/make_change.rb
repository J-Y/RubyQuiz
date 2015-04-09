#!/usr/bin/env ruby19
# Author::      Thomas Link (micathom AT gmail com)
# Created::     2008-01-25.

def make_change(amount, coins = [25, 10, 5, 1])
   return nil if coins.empty? or !amount.is_a?(Integer)
   # I use the ruby19 syntax here in order to make sure this code isn't
   # run with ruby18 (because of the return statements).
   changer = ->(amount, coins, max_size) do
       return [] if amount == 0
       return nil if coins.empty? or
           max_size <= 0 or
           (amount.odd? and coins.all? {|c| c.even?})
       set = nil
       max_size1 = max_size - 1
       coins.each_with_index do |coin, i|
           n_coins = amount / coin
           # The coin value is getting too small
           break if n_coins > max_size
           if amount >= coin
               if amount % coin == 0
                   # Since coins are sorted in descending order,
                   # this is the optimal solution.
                   set = [coin] * n_coins
                   break
               else
                   other = changer.call(amount - coin,
                                        coins[i, coins.size],
                                        max_size1)
                   if other
                       set = other.unshift(coin)
                       max_size  = set.size - 1
                       max_size1 = max_size - 1
                   end
               end
           end
       end
       return set
   end

   coins  = coins.sort_by {|a| -a}
   # We don't care about micro-pennies.
   amount = amount.to_i
   changer.call(amount, coins, amount / coins.last)
end


if __FILE__ == $0
   args  = ARGV.map {|e| e.to_i}
   coins = make_change(args.shift, (args.empty? ? [25, 10, 5, 1] : args).sort_by {|a| -a})
   if coins
       puts "#{coins.inject(0) {|a, c| a += c}}/#{coins.size}: #{coins.join(' ')}"
   else
       puts "Please go away."
   end
end
