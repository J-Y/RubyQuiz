class Solution
 attr_reader :remaining_amount, :coins, :usable_coins

 def initialize(amount, usable_coins, coins=[])
   @remaining_amount = amount
   @usable_coins = usable_coins.sort.reverse.select {|x| x <= amount}
   @coins = coins
 end

 def explode
   # check if this is an invalid branch or already a solution
   return [] if @usable_coins.empty?
   return [] if @usable_coins.last > @remaining_amount
   return [] if @remaining_amount == 0
   # generate two possible scenarios: use a coin of the highest value and generate a Solution with less remaining amount
   # but the same set of usable_coins or remove the highest value and generate a Solution with the same remaining amount
   # but less usable_coins
   first = Solution.new(@remaining_amount - @usable_coins.first, @usable_coins, (@coins.dup) << @usable_coins.first)
   second = Solution.new(@remaining_amount, @usable_coins[1..-1], @coins)
   [first, second]
 end

 def is_solution?
   @remaining_amount == 0
 end

 def number_of_coins
   @coins.length
 end

 def to_s
   "[#{@coins.inspect}, #{@remaining_amount}, #{@usable_coins.inspect}]"
 end
end

def make_change(amount, coins = [25, 10, 5, 1])
 queue = []
 solution_so_far = nil
 length_so_far = nil
 queue << Solution.new(amount, coins)
 until queue.empty?
   current = queue.shift
   # prune branches that would result in a worse solution
   next if solution_so_far && current.number_of_coins >= length_so_far
   if current.is_solution?
     solution_so_far = current
     length_so_far = current.number_of_coins
   else
     queue.push(*current.explode)
   end
 end
 return [] if solution_so_far.nil?
 solution_so_far.coins
end
