require 'mathn'

def make_change(amount, coins = [25, 10, 5, 1])
   return nil if coins.empty? or !amount.kind_of?(Integer)
   # Collect the coins' prime factors.
   factors = Hash.new {|h, c| h[c] = Hash[c.prime_division]}

   changer = ->(amount, coins, max_size) do
       return [] if amount == 0
       return nil if coins.empty? or max_size <= 0
       cf = Hash.new(0)
       coins.each {|c| c != 0 && factors[c].each {|f, n| cf[f] += 1}}
       # If all coins have a common prime factor but this prime is no
       # factor of amount, then we cannot build a sum equal the amount
       # with these coins.
       return nil if cf.any? {|f, n| n == coins.size && amount % f != 0}
       set = nil
       coins = coins.dup
       until coins.empty?
           coin = coins.shift
           next if amount < coin
           n_coins = amount.div(coin)
           break if n_coins > max_size
           n_coins.downto(1) do |j|
               other = changer.call(amount - coin * j, coins, max_size - j)
               if other
                   set = ([coin] * j) + other
                   max_size = set.size - 1
               end
           end
       end
       return set
   end

   coins = coins.sort_by {|a| -a}
   coins.reject! {|c| c == 0 || c > amount}
   changer.call(amount, coins, amount)
end
