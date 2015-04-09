#select what to do when can't make exact change
STRATEGY=[:RoundDown,:RoundUp,:Refuse][1]

class Array
 def sum
   inject(0){|s,v|s+v}
 end
end

def minimum_change coins,strategy
 case STRATEGY
   when :RoundDown
     0
   when :RoundUp
     coins[0]
   when :Refuse
     nil
 end
end

#make amount of change with the fewest possible coins
#
# iterate through progressively larger sets of coins
# until you find a set that adds up to amount,
def make_change(amount, coins = [25, 10, 5, 1])
 change = Array.new(amount+1)
 coins=coins.sort
 #handle cases where change is less than smallest coin
 return [minimum_change(coins,STRATEGY)] if amount < coins[0]
 #initial sets are one coin
 sets = coins.map{|c|[c]}
 loop do
   sets.each{|set|
     return set.reverse if set.sum==amount
     #  record the first set to match each sum  (incase we can't make exact change)
     change[set.sum]||=set
   }
   #generate more sets by adding 1 of each coin to existing sets
   #only keep unique sums smaller than target amount.
   sets = sets.inject([]){|result,set|
     newsets=coins.map{|c|(set+[c]).sort}.find_all{|s|s.sum<=amount }
     result+newsets
   }.uniq
   #if we can't make exact change, reduce amount until we can
   if sets.empty?
     amount -=1 until change[amount]
     #use STRATEGY to round up or down
     minchange=minimum_change(coins,STRATEGY)
     return (change[amount].reverse<<minchange)-[0] if minchange
     return minchange
   end
 end
end
