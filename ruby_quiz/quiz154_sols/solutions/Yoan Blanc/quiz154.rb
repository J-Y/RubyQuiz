#!/usr/bin/ruby
#
# Author: Yoan Blanc <yoan at dosimple dot ch>
# Revision: 20080127

=begin
Making Change (#154)
--------------------

	http://www.rubyquiz.com/quiz154.html

In "Practical Ruby Projects," the author includes a couple of chapters involving coin simulations. These simulators are used to explore the possibilities of replacing a certain coin or adding a new coin.

One interesting subproblem of these simulations is that of making change. For example, if we need to give 39 cents change in the United States (where there are 25, 10, 5, and 1 cent pieces), we can give:

	>> make_change(39)
	=> [25, 10, 1, 1, 1, 1]

What if the coins were 10, 7, and 1 cent pieces though and we wanted to make 14 cents change? We would probably want to do:

	>> make_change(14, [10, 7, 1])
	=> [7, 7]

=end

def make_change(amount, coins=[25, 10, 5, 1])
	
	# Does the change, recursively with a kind of
	# alpha-beta pruning (whitout the beta)
	# Best default value for alpha is +Infinity as
	# alpha represents the size of the actual found
	# solution, it can only decrease with the time.
	def make_change_r(amount, coins, alpha)
		# the coin with its solution 
		# that has to be the shortest one
		best_coin = nil
		solution = []
		
		# The good coin exists (win!)
		if coins.include? amount
			best_coin = amount
		
		# Only one coin stand (avoids a lot of recursion)
		elsif coins.length == 1
			coin = coins[0]
			unless coin > amount or amount % coin != 0
				# Do not construct a solution if this one
				# is bigger than the allowed one (alpha).
				size = amount/coin - 1
				if size <= alpha
					best_coin = coin
					solution = [best_coin] * size
				end
			end
		
		# No solution can be found (odd coins and even amount)
		elsif amount % 2 === 1 and \
				coins.select{|coin| coin % 2 != 0}.length === 0 
			# pass
			
		# Alpha(-beta) pruning:
		# Do not look to this subtree because another
		# shorter solution has been found already.
		elsif alpha > 1 and 
			
			coins.select{|c| c >= amount/alpha}.each do |coin|
				# only give a subset of the coins, the bigger ones
				# have been tested already.
				found = make_change_r( \
					amount-coin, \
					coins.select {|c| c <= coin and c <= amount-coin}, \
					alpha-1)
				
				# Check if the solution (if there is any) is good enough
				if not found.nil? and \
						(solution.length === 0 or solution.length > found.length)
					
					best_coin = coin
					solution = found
					alpha = solution.length
				end
			end
		end
		
		return best_coin.nil? \
			? best_coin \
			: [best_coin] + solution
	end
	
	# Any money or coins to give back?
	if not amount.nil? and amount > 0 and not coins.nil?
		
		# make sure the coins are ready to be used
		coins.sort!
		coins.uniq!
		coins.reverse!
	
		infinity = 1.0/0
		return make_change_r(amount, coins, infinity)
	else
		return []
	end
end
