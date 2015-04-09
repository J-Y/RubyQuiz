def first_non_zero(array)
  first_non_zero = -1
  array.each_with_index do |m,idx|
    if m > 0
      first_non_zero = idx
      break
    end
  end
  first_non_zero
end

# Return optimum change for the given amount and coin values.  If no
# solution exists, returns nil
def make_change(amount, coins = [25, 10, 5, 1])
  puts "Amount: #{amount}  coins: #{coins.inspect}"

  # 0. Sort coins by value
  coins = coins.sort.reverse
  # 1. Minimum number of each coin in amount (prune the search space a bit)
  mins = coins.map {|c| amount / c }
  # 2. If amount is evenly divisible by coin, store the number of coins
  exact_change = coins.map {|c| amount % c == 0 ? amount / c : -1 }

  # Figure out min coins so far, or amount if the amount is not
  # factorable by one of the coin values
  min_coins = exact_change.sort.find {|n| n > 0 } || (amount / coins.last)
  optimum_change = []

  while mins.find {|m| m > 0}
    change = coins.map {|c| 0 }
    coin_count = 0
    fnz = first_non_zero(mins)
    coin_count = mins[fnz]
    current_amount = mins[fnz] * coins[fnz]
    change[fnz] = coin_count
    nci = fnz + 1
    while nci < coins.length && coin_count < min_coins && current_amount < amount
      amount_left = amount - current_amount
      num_next = amount_left / coins[nci]
      coin_count += num_next
      current_amount += num_next * coins[nci]
      change[nci] = num_next
      nci = nci + 1
    end

    # Keep track of optimum solution(s)
    if current_amount == amount && coin_count <= min_coins
      min_coins = coin_count
      optimum_change << change.dup
    end
    # Reduce the first non zero minimum by one, unless it is greater than
    # the current min number of coins.  In that case, drop it to the current
    # minimum number of coins
    mins[fnz] = mins[fnz] > min_coins ? min_coins : mins[fnz] - 1
  end

  # Print out the solutions, but the last is the optimum
  result = []
  optimum_change.each do |solution|
    result = []
    solution.each_with_index do |count, idx|
      count.times { result << coins[idx] }
    end

    puts "#{result.inspect}: #{result.size} #{result.inject(0) {|sum, val| sum += val}}"
  end

  return result.size > 0 ? result : nil
 
end

# Mine doesn't do so well on this one :(
#make_change( 2**100-1, (1..100).map{ |n| 2**n } )
make_change( 7, [5, 3] )
make_change(24,[10,8,2])
make_change(11,[10,9,2])
make_change(1023, (1..10).map{|n| 2**n})
make_change(497, [100, 99, 1])
make_change(397, [100, 99, 1])
make_change(297, [100, 99, 1])
make_change(1_000_001, [1_000_000, 2, 1])
make_change(4563, [97, 89, 83, 79, 73, 71, 67, 61, 59, 53, 47, 43, 41,
37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3])
make_change(1000001, [1000000, 1])
make_change(14, [10,7,1])
make_change(21, [10,7,1])
make_change(14, [10,5,3])
