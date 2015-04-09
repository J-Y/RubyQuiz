def make_change(amount, coins = [25, 10, 5, 1])
	return "no solution" if amount==0
	init_amount=amount
	possible_change = []
	change = []
	coins.sort!
	
	#iterates through each coin to make the change, making all possible sets of change
	(coins.length-1).downto(0) do |start_coin|
		start_coin.downto(0) do |x|
			while amount>= coins[x]
				if (amount - coins[x])>= 0
					amount -= coins[x]
					change<< coins[x]
				else
					next
				end
			end
			
			if amount==0 then
				possible_change< 0
		change = possible_change.sort[0][1]
	else
		change = ["no solution"]
	end

       #print some pretty text
	print "#{init_amount}: #{change.join(', ')}\n"
end
