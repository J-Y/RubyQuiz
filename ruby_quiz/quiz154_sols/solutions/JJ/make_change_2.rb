def make_change(amount, coins = [25, 10, 5, 1])
  return []  if amount <= 0
  return nil if coins == nil

  coins = [nil] + coins # Use 1-based indexing
  table = [[0] * coins.size]
  amount.times { table << Array.new(coins.size) }

  for i in 1 ... table.size do
    for j in 1 ... table[i].size do
      coin = coins[j]
      poss = [table[i][j - 1]]
      if i >= coin && table[i - coin][j] then
        poss << table[i - coin][j] + 1
      end
      table[i][j] = poss.compact.sort.first
    end
  end

  # Walk the solution from the last index to the first
  return nil unless table[-1][-1]

  soln = []
  i = table.size - 1
  j = table[i].size - 1

  while i > 0 && j > 0 do
    if table[i][j - 1] == table[i][j] then
      j -= 1
    else
      soln << coins[j]
      i -= coins[j]
    end
  end

  return soln
end
